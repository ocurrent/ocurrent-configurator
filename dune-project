(lang dune 3.0)

(name ocurrent-configurator)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name ocurrent-configurator)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  ocaml
  dune
  (current (>= 0.6.4))
  ocluster ; needed for ocluster-admin
  current_web
  current_git
  current_github
  current_docker
  current_slack
  prometheus
  prometheus-app)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
