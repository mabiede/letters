#!/bin/sh

# immediately when a command fails and print each command
set -ex

sudo chown -R opam: _build

opam init -a --shell=zsh

make deps
