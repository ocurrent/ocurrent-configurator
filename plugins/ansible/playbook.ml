open Sexplib.Std

type t = {
  name : string;
  content : string [@default ""] [@sexp_drop_default (fun _ _  -> true)];
} [@@deriving sexp]

let v ~name ~content = { name; content }

let name t = t.name

let pp f { name; _ } =
  Fmt.pf f "%s" name

let compare = compare

let equal = (=)

let digest { name; content } =
  Yojson.Safe.to_string @@ `Assoc [
    "name", `String name;
    "content", `String content;
  ]

let marshal t = digest t

let unmarshal s =
  let open Yojson.Safe.Util in
  let json = Yojson.Safe.from_string s in
  let name = json |> member "name" |> to_string in
  let content = json |> member "content" |> to_string in
  { name = name; content }
