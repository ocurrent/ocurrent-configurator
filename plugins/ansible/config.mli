type t

val v : name:string -> playbooks:Playbook.t list -> t
val name : t -> string
val playbooks : t -> Playbook.t list
val equal : t -> t -> bool
val compare : t -> t -> int
val pp : t Fmt.t
val digest : t -> string
val marshal : t -> string
val unmarshal : string -> t
val load : string -> t
