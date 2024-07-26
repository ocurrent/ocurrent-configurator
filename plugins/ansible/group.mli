type t = { configs : Config.t list }

val configs : t -> Config.t list
val marshal : t -> string
val unmarshal : string -> t
