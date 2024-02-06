open Sexplib.Std

type t = {
  name : string;
  content : string [@default ""] [@sexp_drop_default (fun _ _  -> true)];
  validity : int option [@sexp.option];
  inventory : string option [@sexp.option];
  limit : string list option [@sexp.option];
  deps : string list option [@sexp.option];
} [@@deriving sexp]

let v ~name ~content ~validity ~inventory ~limit ~deps =
  { name; content; validity; inventory; limit; deps }

let name t = t.name

let validity t = t.validity

let inventory t = t.inventory

let limit t = t.limit

let deps t = t.deps

let pp f { name; _ } =
  Fmt.pf f "%s" name

let compare = compare

let equal = (=)

let digest { name; content; validity; inventory; limit; deps } =
  let j = [
    "name", `String name;
    "content", `String content;
  ] in
  let j = match validity with
    | Some v -> ("validity", `Int v) :: j
    | None -> j in
  let j = match inventory with
    | Some v -> ("inventory", `String v) :: j
    | None -> j in
  let j = match limit with
    | Some v -> ("limit", `List (List.map (fun x -> `String x) v)) :: j
    | None -> j in
  let j = match deps with
    | Some v -> ("deps", `List (List.map (fun x -> `String x) v)) :: j
    | None -> j in
  Yojson.Safe.to_string @@ `Assoc j

let marshal t = digest t

let unmarshal s =
  let open Yojson.Safe.Util in
  let json = Yojson.Safe.from_string s in
  let name = json |> member "name" |> to_string in
  let content = json |> member "content" |> to_string in
  let validity = json |> member "validity" |> to_int_option in
  let inventory = json |> member "inventory" |> to_string_option in
  let to_list_option lst = match lst with [] -> None | l -> Some l in
  let limit = json |> member "limit" |> to_list |> List.map (to_string) |> to_list_option in
  let deps = json |> member "deps" |> to_list |> List.map (to_string) |> to_list_option in
  { name = name; content; validity; inventory; limit; deps }
