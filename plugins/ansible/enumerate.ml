open Lwt.Infix

type t = {
  pool : unit Current.Pool.t option;
  timeout : Duration.t option;
  level : Current.Level.t option;
}

let id = "docker-build"

module Key = struct
  type t = {
    commit : [ `No_context | `Git of Current_git.Commit.t | `Dir of Fpath.t ];
    limit : string list option;
    playbook : string option;
    inventory : string option;
  }

  let source_to_json = function
    | `No_context -> `Null
    | `Git commit -> `String (Current_git.Commit.hash commit)
    | `Dir path -> `String (Fpath.to_string path)

  let to_json { commit; limit; playbook; inventory } =
    `Assoc [
      "commit", source_to_json commit;
      "limit", [%derive.to_yojson:string list option] limit;
      "playbook", [%derive.to_yojson:string option] playbook;
      "inventory", [%derive.to_yojson:string option] inventory;
    ]

  let digest t = Yojson.Safe.to_string (to_json t)

  let pp f t = Yojson.Safe.pretty_print f (to_json t)
end

module Value = struct
  type t = {
    playbooks : (string * string) list
  }

  let digest { playbooks } =
    Yojson.Safe.to_string @@ `Assoc [
      "playbooks", `Assoc (List.map (fun (name, content) -> name, `String content) playbooks);
    ]

  let marshal t = digest t

  let unmarshal s =
    let open Yojson.Safe.Util in
    let json = Yojson.Safe.from_string s in
    let playbooks = json |> member "playbooks" |> to_assoc |> List.map (fun (n, c) -> n, (to_string c)) in
    { playbooks }
end

let with_context ~job context fn =
  let open Lwt_result.Infix in
  match context with
  | `No_context -> Current.Process.with_tmpdir ~prefix:"ansible-context-" fn
  | `Dir path ->
      Current.Process.with_tmpdir ~prefix:"ansible-context-" @@ fun dir ->
      Current.Process.exec ~cwd:dir ~cancellable:true ~job ("", [| "rsync"; "-aHq"; Fpath.to_string path ^ "/"; "." |]) >>= fun () ->
      fn dir
  | `Git commit -> Current_git.with_checkout ~job commit fn

let read_whole_file filename =
    let ch = open_in_bin filename in
    let s = really_input_string ch (in_channel_length ch) in
    close_in ch;
    s

let build { pool; timeout; level } job key =
  let { Key.commit; limit; playbook; inventory } = key in
  let level = Option.value level ~default:Current.Level.Average in
  Current.Job.start ?timeout ?pool job ~level >>= fun () ->
  with_context ~job commit @@ fun dir ->
          let _ = limit in
          let _ = playbook in
          let _ = inventory in
  let dir = Fpath.to_string dir in
  let yaml_files = Sys.readdir dir |> Array.to_list |> List.filter (fun x -> Filename.extension x  = ".yml") in
  let playbooks = List.map (fun yml -> yml, read_whole_file (dir ^ "/" ^ yml)) yaml_files in
  Lwt.return (Stdlib.Result.ok { Value.playbooks })

let pp f key = Fmt.pf f "@[<v2>Ansible parameters %a@]" Key.pp key

let auto_cancel = true
