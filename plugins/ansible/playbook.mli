type t
val v : name:string -> content:string -> validity:int option -> t
val name : t -> string
val validity : t -> int option
val equal : t -> t -> bool
val compare : t -> t -> int
val pp : t Fmt.t
val digest : t -> string
val marshal : t -> string
val unmarshal : string -> t
val t_of_sexp : Sexplib0.Sexp.t -> t
val sexp_of_t : t -> Sexplib0.Sexp.t
