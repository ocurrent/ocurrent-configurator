#!/bin/sh

# Generate known_hosts file
mkdir ~/.ssh
for host in \
  x86-bm-c4.sw.ocaml.org \
  x86-bm-c5.sw.ocaml.org \
  x86-bm-c6.sw.ocaml.org \
  x86-bm-c7.sw.ocaml.org \
  x86-bm-c8.sw.ocaml.org \
  x86-bm-c9.sw.ocaml.org \
  leafcutter.caelum.ci.dev \
  carpenter.caelum.ci.dev \
  riscv-worker-01.caelum.ci.dev \
  riscv-worker-02.caelum.ci.dev \
  riscv-worker-03.caelum.ci.dev \
  ci3.ocamllabs.io \
  ci4.ocamllabs.io \
  ci.mirage.io \
  ci.ocamllabs.io \
  deploy.ci.ocaml.org \
  dev1.ocamllabs.io \
  docs.ci.ocaml.org \
  staging.docs.ci.ocamllabs.io \
  opam-4.ocaml.org \
  opam-5.ocaml.org \
  v2.ocaml.org \
  v3b.ocaml.org \
  v3c.ocaml.org \
  watch.ocaml.org \
  opam.ci.ocaml.org \
  ocaml.ci.dev \
  check.ci.ocaml.org \
  147.75.84.37 ; do
  ssh-keyscan -H -t ecdsa-sha2-nistp256 $host >> ~/.ssh/known_hosts
done
chmod 700 ~/.ssh
chmod 600 ~/.ssh/known_hosts

# Add the deployer key
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvUrmcVa69xhR2ZL8i4AyvPnFAM3fQ/Pyi5s7b0L9Lv" > ~/.ssh/id_ed25519.pub
ln -s /run/secrets/configurator-private-key ~/.ssh/id_ed25519
