FROM ocaml/opam:ubuntu-24.04-ocaml-4.14 AS build
RUN sudo apt update && sudo apt install pkg-config libgmp-dev graphviz libev-dev libffi-dev libsqlite3-dev capnproto libcapnp-dev -y --no-install-recommends
RUN sudo ln -f /usr/bin/opam-2.2 /usr/bin/opam && opam init --reinit -ni
RUN opam option solver=builtin-0install
RUN cd ~/opam-repository && git fetch -q origin master && opam update
WORKDIR /src
COPY --chown=opam ocurrent-configurator.opam /src/
RUN opam pin -yn add .
RUN opam install -y --deps-only .
RUN opam install ocluster -y
ADD --chown=opam . .
RUN opam config exec -- dune build ./_build/install/default/bin/ocurrent-configurator

FROM ubuntu:noble
RUN apt update && apt install libsqlite3-dev libev-dev ca-certificates git netbase graphviz ssh curl gpg -y --no-install-recommends
RUN apt update && apt install ansible -y --no-install-recommends
WORKDIR /var/lib/ocurrent-configurator
ENTRYPOINT ["/usr/local/bin/ocurrent-configurator"]
COPY configure-ssh.sh /usr/local/bin/configure-ssh
RUN configure-ssh
COPY --from=build /home/opam/.opam/4.14/bin/ocluster-admin /usr/local/bin/
COPY --from=build /src/_build/install/default/bin/ocurrent-configurator /usr/local/bin/
