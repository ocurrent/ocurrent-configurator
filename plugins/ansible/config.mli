type t
val v : playbooks:Playbook.t list -> t
val playbooks : t -> Playbook.t list
val equal : t -> t -> bool
val compare : t -> t -> int
val pp : t Fmt.t
val digest : t -> string
val marshal : t -> string
val unmarshal : string -> t
