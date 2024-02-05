open Current.Syntax

module Playbook = Playbook
module Config = Config

let src = Logs.Src.create "ansible" ~doc:"OCurrent Ansible plugin"
module Log = (val Logs.src_log src : Logs.LOG)

module Play_cache = Current_cache.Make(Play)

let play ?level ?schedule ?timeout ?inventory ?limit ?playbook commit =
  Current.component "ansible-playbook %s" (Option.value playbook ~default:"playbook.yml") |>
  let> commit = commit in
  Play_cache.get ?schedule { pool = None; timeout; level }
  { commit; limit; playbook; inventory }

module Configure_cache = Current_cache.Make(Configure)

let configure ?level ?schedule ?timeout ?inventory ?limit ?playbook commit =
  Current.component "configure" |>
  let> commit = commit in
  Configure_cache.get ?schedule { pool = None; timeout; level }
  { commit; limit; playbook; inventory }

module Run_cache = Current_cache.Make(Run)

let run commit playbook =
  Current.component "ansible-playbook" |>
  let> playbook = playbook
  and+ commit = commit in
  let schedule = match Playbook.validity playbook with
  | None -> None
  | Some days -> Some (Current_cache.Schedule.v ~valid_for:(Duration.of_day days) ()) in
  Run_cache.get ?schedule { commit } { playbook }
