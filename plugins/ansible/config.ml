open Sexplib
open Sexplib.Std

type t = {
  playbooks : Playbook.t list
} [@@deriving sexp]

let v ~playbooks = { playbooks }

let playbooks t = t.playbooks

let pp f t =
  let _ = t in
  Fmt.pf f "lst"

let compare = compare

let equal = (=)

let digest { playbooks } =
  Yojson.Safe.to_string @@ `Assoc [
    "playbooks", `List (List.map (fun p -> `String (Playbook.marshal p)) playbooks);
  ]

let marshal t = digest t

let unmarshal s =
  let open Yojson.Safe.Util in
  let json = Yojson.Safe.from_string s in
  let playbooks = json |> member "playbooks" |> to_list |>
  List.map (fun el ->
    match el with
    | `String s -> Playbook.unmarshal s
    | _ -> failwith "Expected playbook") in
  { playbooks }

let load file =
  Sexp.load_sexp file |> t_of_sexp
