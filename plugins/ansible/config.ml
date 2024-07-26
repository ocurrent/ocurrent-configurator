open Sexplib
open Sexplib.Std

type t = {
  name : string;
  playbooks : Playbook.t list;
}
[@@deriving sexp]

let v ~name ~playbooks = { name; playbooks }
let name t = t.name
let playbooks t = t.playbooks
let pp f t = Fmt.pf f "%s" t.name
let compare = compare
let equal = ( = )

let digest { name; playbooks } =
  Yojson.Safe.to_string @@ `Assoc [ ("name", `String name); ("playbooks", `List (List.map (fun p -> `String (Playbook.marshal p)) playbooks)) ]

let marshal t = digest t

let unmarshal s =
  let open Yojson.Safe.Util in
  let json = Yojson.Safe.from_string s in
  let name = json |> member "name" |> to_string in
  let playbooks =
    json |> member "playbooks" |> to_list
    |> List.map (fun el ->
           match el with
           | `String s -> Playbook.unmarshal s
           | _ -> failwith "Expected playbook")
  in
  { name; playbooks }

let load file = Sexp.load_sexp file |> t_of_sexp
