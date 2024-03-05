(* Usage: github.exe SOURCE --github-token-file GITHUB-TOKEN-FILE --github-webhook-secret-file GITHUB-APP-SECRET

   Given a Github repository SOURCE, build the latest version on the default branch
   using Docker and OCaml 4.13. Updates to the GitHub repository will trigger webhooks on
   "webhooks/github", so some suitable forwarding of webhooks from GitHub to localhost needs
   to be setup eg smee.io, along with a suitable token and webhook secret.

*)

let program_name = "ocurrent-configurator"

module Git = Current_git
module Github = Current_github
module Ansible = Current_ansible

let () = Prometheus_unix.Logging.init ()

(* Link for GitHub statuses. *)
(*
let url = Uri.of_string "http://5.102.169.176:8080"
*)

(* Access control policy *)
let has_role user role =
  match user with
  | None -> role = `Viewer || role = `Monitor         (* Unauthenticated users can only look at things. *)
  | Some user ->
    match Current_web.User.id user, role with
    | ("github:mtelvers"), _ -> true        (* These users have all roles *)
    | _ -> role = `Viewer

(*
let github_status_of_state = function
  | Ok _              -> Github.Api.Status.v ~url `Success ~description:"Passed"
  | Error (`Active _) -> Github.Api.Status.v ~url `Pending
  | Error (`Msg m)    -> Github.Api.Status.v ~url `Failure ~description:m
  *)

let pipeline ~github ~repo () =
        (*
        let repo2 = { Github.Repo_id.owner = "mtelvers"; name = "ansible" } in
        let refs = Github.Api.ci_refs github repo2 in
        let pipeline = refs |> Current.list_iter (module Github.Api.Commit) @@ fun commit ->
          let src = Current_git.fetch (Current.map Github.Api.Commit.id commit) in
          Ansible.play ~schedule:weekly ~limit:["x86-bm-c4.sw.ocaml.org"] (Current.map (fun src -> `Git src) src) |>
          Current.state |> Current.map github_status_of_state |> Github.Api.Commit.set_status commit "ocurrent" in
*)
  let name = "live" in
  let commit = Github.Api.head_of github repo (`Ref ("refs/heads/" ^ name)) in
  let src = Current_git.fetch (Current.map Github.Api.Commit.id commit) in
  let pool = Current.Pool.create ~label:"ansible" 1 in
  let pipeline = 
  Ansible.configure (Current.map (fun src -> `Git src) src)
  |> Current.map (Ansible.Config.playbooks)
  |> Current.list_iter (module Ansible.Playbook) (fun s -> Ansible.run ~pool src s) in
  (*
  let pipeline2 =
  Ansible.configure ~schedule:weekly ~limit:["x86-bm-c4.sw.ocaml.org"] (Current.map (fun src -> `Git src) src)
  |> Current.state
  |> Current.map github_status_of_state
  |> Github.Api.Commit.set_status commit "ocurrent" in
  Current.all ([pipeline; pipeline2])
*)
  Current.all ([pipeline])

let main config auth mode github repo =
  let engine = Current.Engine.create ~config (pipeline ~github ~repo) in
  (* this example does not have support for looking up job_ids for a commit *)
  let get_job_ids = (fun ~owner:_owner ~name:_name ~hash:_hash -> []) in
  let routes =
    Routes.(s "login" /? nil @--> Current_github.Auth.login auth) ::
    Routes.(s "webhooks" / s "github" /? nil @--> Github.webhook ~engine ~get_job_ids ~webhook_secret:(Github.Api.webhook_secret github)) ::
    Current_web.routes engine
  in
  let site = Current_web.Site.(v ?authn:(Option.map Current_github.Auth.make_login_uri auth) ~has_role) ~name:program_name routes in
  Lwt_main.run begin
    Lwt.choose [
      Current.Engine.thread engine;
      Current_web.run ~mode site;
    ]
  end

(* Command-line parsing *)

open Cmdliner

let repo =
  Arg.required @@
  Arg.pos 0 (Arg.some Github.Repo_id.cmdliner) None @@
  Arg.info
    ~doc:"The GitHub repository (owner/name) to monitor."
    ~docv:"REPO"
    []

let cmd =
  let doc = "Monitor a GitHub repository." in
  let info = Cmd.info program_name ~doc in
  Cmd.v info Term.(term_result (const main $ Current.Config.cmdliner $ Current_github.Auth.cmdliner $ Current_web.cmdliner $ Current_github.Api.cmdliner $ repo))

let () = exit @@ Cmd.eval cmd
