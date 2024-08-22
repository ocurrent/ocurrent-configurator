open Sexplib
open Sexplib.Std

type t = {
  name : string;
  label : string option; [@sexp.option]
  content : string option; [@sexp.option]
  validity : int option; [@sexp.option]
  inventory : string option; [@sexp.option]
  vars : string option; [@sexp.option]
  limit : string list option; [@sexp.option]
  deps : string list option; [@sexp.option]
}
[@@deriving sexp]

let v ~name ~label ~content ~validity ~inventory ~vars ~limit ~deps = { name; label; content; validity; inventory; vars; limit; deps }
let name t = t.name
let label t = t.label
let validity t = t.validity
let inventory t = t.inventory
let vars t = t.vars
let limit t = t.limit
let deps t = t.deps
let compare = compare
let equal = ( = )
let marshal t = sexp_of_t t |> Sexp.to_string
let unmarshal s = Sexp.of_string s |> t_of_sexp

let pp f { name; label; _ } =
  match label with
  | Some v -> Fmt.pf f "%s" v
  | _ -> Fmt.pf f "%s" name
