let src = Logs.Src.create "current.ansible" ~doc:"OCurrent Ansible plugin"
include (val Logs.src_log src : Logs.LOG)
