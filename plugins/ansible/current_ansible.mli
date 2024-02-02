val play : ?level:Current.Level.t -> ?schedule:Current_cache.Schedule.t -> ?timeout:Duration.t -> ?inventory:string -> ?limit:string list -> ?playbook:string -> [ `Git of Current_git.Commit.t | `Dir of Fpath.t | `No_context ] Current.t -> string Current.t

val enumerate : ?level:Current.Level.t -> ?schedule:Current_cache.Schedule.t -> ?timeout:Duration.t -> ?inventory:string -> ?limit:string list -> ?playbook:string -> [ `Git of Current_git.Commit.t | `Dir of Fpath.t | `No_context ] Current.t -> Enumerate.Value.t Current.t
