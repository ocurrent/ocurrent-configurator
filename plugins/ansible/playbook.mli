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

val v :
  name:string ->
  label:string option ->
  content:string option ->
  validity:int option ->
  inventory:string option ->
  vars:string option ->
  limit:string list option ->
  deps:string list option ->
  t

val name : t -> string
val label : t -> string option
val validity : t -> int option
val inventory : t -> string option
val vars : t -> string option
val limit : t -> string list option
val deps : t -> string list option
val equal : t -> t -> bool
val compare : t -> t -> int
val pp : t Fmt.t
val marshal : t -> string
val unmarshal : string -> t
val t_of_sexp : Sexplib0.Sexp.t -> t
val sexp_of_t : t -> Sexplib0.Sexp.t
