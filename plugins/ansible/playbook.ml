open Sexplib.Std

type t = {
  name : string;
  content : string [@default ""] [@sexp_drop_default (fun _ _  -> true)];
  validity : int option [@sexp.option];
} [@@deriving sexp]

let v ~name ~content ~validity = { name; content; validity }

let name t = t.name

let validity t = t.validity

let pp f { name; _ } =
  Fmt.pf f "%s" name

let compare = compare

let equal = (=)

let digest { name; content; validity } =
  let j = [
    "name", `String name;
    "content", `String content;
  ] in
  let j = match validity with
    | Some v -> ("validity", `Int v)  :: j
    | None -> j in
  Yojson.Safe.to_string @@ `Assoc j

let marshal t = digest t

let unmarshal s =
  let open Yojson.Safe.Util in
  let json = Yojson.Safe.from_string s in
  let name = json |> member "name" |> to_string in
  let content = json |> member "content" |> to_string in
  let validity = json |> member "validity" |> to_int_option in
  { name = name; content; validity }
