FROM ocaml/opam:debian-12-ocaml-4.14 AS build
RUN sudo apt update && sudo apt install pkg-config libgmp-dev graphviz libev-dev libffi-dev libsqlite3-dev capnproto libcapnp-dev -y --no-install-recommends
RUN cd ~/opam-repository && git fetch -q origin master && opam update
WORKDIR /src
COPY --chown=opam ocurrent-configurator.opam /src/
RUN opam pin -yn add .
RUN opam install -y --deps-only .
RUN opam install ocluster -y
ADD --chown=opam . .
RUN opam config exec -- dune build ./_build/install/default/bin/ocurrent-configurator

FROM debian:12
RUN apt update && apt install libsqlite3-dev libev-dev ca-certificates git netbase graphviz curl gpg -y --no-install-recommends
RUN curl -Ls "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu jammy main" | tee /etc/apt/sources.list.d/ansible.list
RUN apt update && apt install ansible -y --no-install-recommends
WORKDIR /var/lib/ocurrent-configurator
ENTRYPOINT ["/usr/local/bin/ocurrent-configurator"]
COPY configure-ssh.sh /usr/local/bin/configure-ssh
RUN configure-ssh
COPY --from=build /home/opam/.opam/4.14/bin/ocluster-admin /usr/local/bin/
COPY --from=build /src/_build/install/default/bin/ocurrent-configurator /usr/local/bin/
