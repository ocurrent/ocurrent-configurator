#!/bin/sh

# Generate known_hosts file
mkdir ~/.ssh
for host in \
  x86-bm-c1.sw.ocaml.org \
  x86-bm-c2.sw.ocaml.org \
  x86-bm-c3.sw.ocaml.org \
  x86-bm-c4.sw.ocaml.org \
  x86-bm-c5.sw.ocaml.org \
  x86-bm-c6.sw.ocaml.org \
  x86-bm-c7.sw.ocaml.org \
  x86-bm-c8.sw.ocaml.org \
  x86-bm-c9.sw.ocaml.org \
  x86-bm-c10.sw.ocaml.org \
  x86-bm-c11.sw.ocaml.org \
  x86-bm-c12.sw.ocaml.org \
  x86-bm-c13.sw.ocaml.org \
  x86-bm-c14.sw.ocaml.org \
  x86-bm-c15.sw.ocaml.org \
  x86-bm-c16.sw.ocaml.org \
  x86-bm-c17.sw.ocaml.org \
  x86-bm-c18.sw.ocaml.org \
  x86-bm-c19.sw.ocaml.org \
  x86-bm-c20.sw.ocaml.org \
  leafcutter.caelum.ci.dev \
  carpenter.caelum.ci.dev \
  riscv-bm-a1.sw.ocaml.org \
  riscv-bm-a2.sw.ocaml.org \
  riscv-bm-a3.sw.ocaml.org \
  riscv-bm-a4.sw.ocaml.org \
  riscv-worker-01.caelum.ci.dev \
  riscv-worker-02.caelum.ci.dev \
  riscv-worker-03.caelum.ci.dev \
  riscv-worker-04.caelum.ci.dev \
  riscv-worker-05.caelum.ci.dev \
  s390x-worker-01.marist.ci.dev \
  s390x-worker-02.marist.ci.dev \
  c2-1.equinix.ci.dev \
  ci3.ocamllabs.io \
  ci4.ocamllabs.io \
  ci.ocamllabs.io \
  deploy.ci.ocaml.org \
  deploy.ci.dev \
  scheduler.ci.dev \
  images.ci.ocaml.org \
  dev1.ocamllabs.io \
  docs.ci.ocaml.org \
  staging.docs.ci.ocamllabs.io \
  opam-4.ocaml.org \
  opam-5.ocaml.org \
  v2.ocaml.org \
  ci.mirageos.org \
  get.dune.build \
  v3b.ocaml.org \
  v3c.ocaml.org \
  watch.ocaml.org \
  opam.ci.ocaml.org \
  ocaml.ci.dev \
  check.ci.ocaml.org \
  registry.ci.dev \
  molpadia.caelum.ci.dev \
  kydoime.caelum.ci.dev \
  ainia.caelum.ci.dev \
  okypous.caelum.ci.dev \
  arm64-jade-2.equinix.ci.dev \
  phoebe.caelum.ci.dev \
  clete.caelum.ci.dev \
  toxis.caelum.ci.dev \
  laodoke.caelum.ci.dev \
  asteria.caelum.ci.dev \
  doris.caelum.ci.dev \
  iphito.caelum.ci.dev \
  marpe.caelum.ci.dev \
  orithia.caelum.ci.dev \
  ocaml-multicore.ci.dev \
  plausible.ci.dev \
  ocaml-1.osuosl.ci.dev \
  ocaml-2.osuosl.ci.dev \
  147.75.84.37 ; do
  ssh-keyscan -H -t ecdsa-sha2-nistp256 $host >> ~/.ssh/known_hosts
done
chmod 700 ~/.ssh
chmod 600 ~/.ssh/known_hosts

# Add the configurator key
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvUrmcVa69xhR2ZL8i4AyvPnFAM3fQ/Pyi5s7b0L9Lv" > ~/.ssh/id_ed25519.pub
ln -s /run/secrets/configurator-private-key ~/.ssh/id_ed25519
