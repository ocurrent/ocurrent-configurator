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

let pipeline ~github ~repo () =
  let name = "live" in
  let commit = Github.Api.head_of github repo (`Ref ("refs/heads/" ^ name)) in
  let src = Current_git.fetch (Current.map Github.Api.Commit.id commit) in
  let pool = Current.Pool.create ~label:"ansible" 1 in
  let pipeline =
    Ansible.configure (Current.map (fun src -> `Git src) src)
    |> Current.map Ansible.Group.configs
    |> Current.list_iter ~collapse_key:"group"
         (module Ansible.Config)
         (fun s -> Current.map Ansible.Config.playbooks s |> Current.list_iter (module Ansible.Playbook) (fun s -> Ansible.run ~pool src s))
  in
  Current.all [ pipeline ]

let main config auth mode github repo =
  let engine = Current.Engine.create ~config (pipeline ~github ~repo) in
  let get_job_ids ~owner:_owner ~name:_name ~hash:_hash = [] in
  let routes =
    Routes.((s "login" /? nil) @--> Current_github.Auth.login auth)
    :: Routes.((s "webhooks" / s "github" /? nil) @--> Github.webhook ~engine ~get_job_ids ~webhook_secret:(Github.Api.webhook_secret github))
    :: Current_web.routes engine
  in
  let site = Current_web.Site.(v ?authn:(Option.map Current_github.Auth.make_login_uri auth) ~has_role) ~name:program_name routes in
  Lwt_main.run (Lwt.choose [ Current.Engine.thread engine; Current_web.run ~mode site ])

(* Command-line parsing *)

open Cmdliner

let repo = Arg.required @@ Arg.pos 0 (Arg.some Github.Repo_id.cmdliner) None @@ Arg.info ~doc:"The GitHub repository (owner/name) to monitor." ~docv:"REPO" []

let cmd =
  let doc = "Monitor a GitHub repository." in
  let info = Cmd.info program_name ~doc in
  Cmd.v info
    Term.(term_result (const main $ Current.Config.cmdliner $ Current_github.Auth.cmdliner $ Current_web.cmdliner $ Current_github.Api.cmdliner $ repo))

let () = exit @@ Cmd.eval cmd
