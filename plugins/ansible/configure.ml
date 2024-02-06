open Lwt.Infix

type t = {
  pool : unit Current.Pool.t option;
  timeout : Duration.t option;
  level : Current.Level.t option;
}

let id = "configure"

module Key = struct
  type t = {
    commit : [ `No_context | `Git of Current_git.Commit.t | `Dir of Fpath.t ];
  }

  let source_to_json = function
    | `No_context -> `Null
    | `Git commit -> `String (Current_git.Commit.hash commit)
    | `Dir path -> `String (Fpath.to_string path)

  let to_json { commit } =
    `Assoc [
      "commit", source_to_json commit;
    ]

  let digest t = Yojson.Safe.to_string (to_json t)

  let pp f t = Yojson.Safe.pretty_print f (to_json t)
end

module Value = Config

let with_context ~job context fn =
  let open Lwt_result.Infix in
  match context with
  | `No_context -> Current.Process.with_tmpdir ~prefix:"ansible-context-" fn
  | `Dir path ->
      Current.Process.with_tmpdir ~prefix:"ansible-context-" @@ fun dir ->
      Current.Process.exec ~cwd:dir ~cancellable:true ~job ("", [| "rsync"; "-aHq"; Fpath.to_string path ^ "/"; "." |]) >>= fun () ->
      fn dir
  | `Git commit -> Current_git.with_checkout ~job commit fn

let build { pool; timeout; level } job key =
  let { Key.commit } = key in
  let level = Option.value level ~default:Current.Level.Average in
  Current.Job.start ?timeout ?pool job ~level >>= fun () ->
  with_context ~job commit @@ fun dir ->
  let dir = Fpath.to_string dir in
  let t = Config.load (dir ^ "/" ^ "configuration.sexp") in
  let playbooks = List.map (fun p ->
    let name = Playbook.name p in
    let validity = Playbook.validity p in
    let inventory = Playbook.inventory p in
    let limit = Playbook.limit p in
    let deps = Some (name :: (Option.value ~default:[] (Playbook.deps p))) in
    let content = Some (Option.value ~default:[] deps |> List.map (fun f -> Digest.file (dir ^ "/" ^ f) |> Digest.to_hex) |> String.concat ",") in
    let playbook = Playbook.v ~name ~content ~validity ~inventory ~limit ~deps in
    let _ = Log.info (fun f -> f "%s" (Playbook.marshal playbook)) in
    playbook
  ) (Config.playbooks t) in
  Lwt.return (Stdlib.Result.ok (Config.v ~playbooks))

let pp f key = Fmt.pf f "@[<v2>Reading parameters from %a@]" Key.pp key

let auto_cancel = true
