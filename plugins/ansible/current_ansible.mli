module Playbook = Playbook
module Config = Config

val play : ?level:Current.Level.t -> ?schedule:Current_cache.Schedule.t -> ?timeout:Duration.t -> ?inventory:string -> ?limit:string list -> ?playbook:string -> [ `Git of Current_git.Commit.t | `Dir of Fpath.t | `No_context ] Current.t -> string Current.t

val configure : ?level:Current.Level.t -> ?schedule:Current_cache.Schedule.t -> ?timeout:Duration.t -> ?inventory:string -> ?limit:string list -> ?playbook:string -> [ `Git of Current_git.Commit.t | `Dir of Fpath.t | `No_context ] Current.t -> Config.t Current.t

val run : Current_git.Commit.t Current.t -> Playbook.t Current.t -> unit Current.t
