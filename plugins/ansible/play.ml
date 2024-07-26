open Lwt.Infix

type t = {
  pool : unit Current.Pool.t option;
  timeout : Duration.t option;
  level : Current.Level.t option;
}

let id = "ansible-play"

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
    `Assoc
      [
        ("commit", source_to_json commit);
        ("limit", [%derive.to_yojson: string list option] limit);
        ("playbook", [%derive.to_yojson: string option] playbook);
        ("inventory", [%derive.to_yojson: string option] inventory);
      ]

  let digest t = Yojson.Safe.to_string (to_json t)
  let pp f t = Yojson.Safe.pretty_print f (to_json t)
end

module Value = Current.String

let with_context ~job context fn =
  let open Lwt_result.Infix in
  match context with
  | `No_context -> Current.Process.with_tmpdir ~prefix:"ansible-context-" fn
  | `Dir path ->
      Current.Process.with_tmpdir ~prefix:"ansible-context-" @@ fun dir ->
      Current.Process.exec ~cwd:dir ~cancellable:true ~job ("", [| "rsync"; "-aHq"; Fpath.to_string path ^ "/"; "." |]) >>= fun () -> fn dir
  | `Git commit -> Current_git.with_checkout ~job commit fn

let build { pool; timeout; level } job key =
  let { Key.commit; limit; playbook; inventory } = key in
  let level = Option.value level ~default:Current.Level.Average in
  Current.Job.start ?timeout ?pool job ~level >>= fun () ->
  with_context ~job commit @@ fun dir ->
  let playbook = Option.value playbook ~default:"playbook.yml" in
  let inventory =
    match inventory with
    | Some i -> [ "-i"; i ]
    | None -> []
  in
  let limit =
    match limit with
    | Some sl -> [ "--limit"; String.concat "," sl ]
    | None -> []
  in
  let _ = Log.info (fun f -> f "dir %s" (Fpath.to_string dir)) in
  let cmd = ("", Array.of_list ("ansible-playbook" :: (inventory @ limit @ [ playbook ]))) in
  let pp_error_command f = Fmt.string f "ansible-playbook" in
  Current.Process.exec ~cwd:dir ~cancellable:true ~pp_error_command ~job cmd >|= function
  | Error _ as e -> e
  | Ok () -> Stdlib.Result.ok "success"

let pp f key = Fmt.pf f "@[<v2>Ansible parameters %a@]" Key.pp key
let auto_cancel = true
