let program_name = "ocurrent-configurator"

module Git = Current_git
module Github = Current_github
module Ansible = Current_ansible

let () = Prometheus_unix.Logging.init ()

(* Access control policy *)
let has_role user role =
  match user with
  | None -> role = `Viewer || role = `Monitor (* Unauthenticated users can only look at things. *)
  | Some user -> (
      match (Current_web.User.id user, role) with
      | "github:mtelvers", _ -> true (* These users have all roles *)
      | _ -> role = `Viewer)

let pipeline ~app () =
  Github.App.installations app |> Current.list_iter (module Github.Installation) @@ fun installation ->
  let repos = Github.Installation.repositories installation in
  repos |> Current.list_iter ~collapse_key:"repo" (module Github.Api.Repo) @@ fun repo ->
  let head = Github.Api.Repo.head_commit repo  in
  let src = Git.fetch (Current.map Github.Api.Commit.id head) in
  let pool = Current.Pool.create ~label:"ansible" 1 in
  let pipeline =
    Ansible.configure (Current.map (fun src -> `Git src) src)
    |> Current.map Ansible.Group.configs
    |> Current.list_iter ~collapse_key:"group"
         (module Ansible.Config)
         (fun s -> Current.map Ansible.Config.playbooks s |> Current.list_iter (module Ansible.Playbook) (fun s -> Ansible.run ~pool src s))
  in
  Current.all [ pipeline ]

let main config auth mode app =
  let engine = Current.Engine.create ~config (pipeline ~app) in
  let webhook_secret = Current_github.App.webhook_secret app in
  let get_job_ids ~owner:_owner ~name:_name ~hash:_hash = [] in
  let routes =
    Routes.((s "login" /? nil) @--> Current_github.Auth.login auth)
    :: Routes.((s "webhooks" / s "github" /? nil) @--> Github.webhook ~engine ~get_job_ids ~webhook_secret)
    :: Current_web.routes engine
  in
  let site = Current_web.Site.(v ?authn:(Option.map Current_github.Auth.make_login_uri auth) ~has_role) ~name:program_name routes in
  Lwt_main.run (Lwt.choose [ Current.Engine.thread engine; Current_web.run ~mode site ])

(* Command-line parsing *)

open Cmdliner

let cmd =
  let doc = "Deploy from a GitHub app's repositories." in
  let info = Cmd.info program_name ~doc in
  Cmd.v info
    Term.(term_result (const main $ Current.Config.cmdliner $ Current_github.Auth.cmdliner $ Current_web.cmdliner $ Current_github.App.cmdliner))

let () = exit @@ Cmd.eval cmd
