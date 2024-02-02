FROM ocaml/opam:debian-12-ocaml-4.14 AS build
RUN sudo apt-get update && sudo apt-get install pkg-config libgmp-dev -y --no-install-recommends
RUN cd ~/opam-repository && git fetch -q origin master && opam update
WORKDIR /src
COPY --chown=opam ocurrent-configurator.opam /src/
RUN opam pin -yn add .
RUN opam install -y --deps-only .
ADD --chown=opam . .
RUN opam config exec -- dune build ./_build/install/default/bin/ocurrent-configurator

FROM debian:12
RUN apt-get update && apt-get install libsqlite3-dev dumb-init netbase -y --no-install-recommends
WORKDIR /var/lib/ocurrent-configurator
ENTRYPOINT ["dumb-init", "/usr/local/bin/ocurrent-configurator"]
COPY --from=build /src/_build/install/default/bin/ocurrent-configurator /usr/local/bin/
