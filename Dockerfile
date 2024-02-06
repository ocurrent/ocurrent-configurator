FROM ocaml/opam:debian-12-ocaml-4.14 AS build
RUN sudo apt-get update && sudo apt-get install pkg-config libgmp-dev graphviz libev-dev libffi-dev libsqlite3-dev capnproto libcapnp-dev -y --no-install-recommends
RUN cd ~/opam-repository && git fetch -q origin master && opam update
WORKDIR /src
COPY --chown=opam ocurrent-configurator.opam /src/
RUN opam pin -yn add .
RUN opam install -y --deps-only .
RUN opam install ocluster -y
ADD --chown=opam . .
RUN opam config exec -- dune build ./_build/install/default/bin/ocurrent-configurator

FROM debian:12
RUN apt-get update && apt-get install libsqlite3-dev libev-dev ca-certificates git netbase ansible -y --no-install-recommends
WORKDIR /var/lib/ocurrent-configurator
ENTRYPOINT ["/usr/local/bin/ocurrent-configurator"]
COPY --from=build /home/opam/.opam/4.14/bin/ocluster-admin /usr/local/bin/
COPY --from=build /src/_build/install/default/bin/ocurrent-configurator /usr/local/bin/
