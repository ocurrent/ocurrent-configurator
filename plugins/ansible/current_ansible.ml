open Current.Syntax

let src = Logs.Src.create "ansible" ~doc:"OCurrent Ansible plugin"
module Log = (val Logs.src_log src : Logs.LOG)

module Play_cache = Current_cache.Make(Play)

let play ?level ?schedule ?timeout ?inventory ?limit ?playbook commit =
  Current.component "ansible-playbook %s" (Option.value playbook ~default:"playbook.yml") |>
  let> commit = commit in
  Play_cache.get ?schedule { pool = None; timeout; level }
  { commit; limit; playbook; inventory }

module Enumerate_cache = Current_cache.Make(Enumerate)

let enumerate ?level ?schedule ?timeout ?inventory ?limit ?playbook commit =
  Current.component "ansible-enumerate %s" "tag" |>
  let> commit = commit in
  Enumerate_cache.get ?schedule { pool = None; timeout; level }
  { commit; limit; playbook; inventory }
