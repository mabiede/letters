#!/bin/sh

# immediately when a command fails and print each command
set -ex

sudo chown -R opam: _build

opam init -a --shell=zsh

opam install ocaml-lsp-server ocamlformat
opam install . --working-dir --with-test --with-doc --deps-only --update-invariant
