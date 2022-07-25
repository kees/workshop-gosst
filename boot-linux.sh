#!/bin/bash
set -eu
set -x

export LANG=C
export DEBIAN_FRONTEND=noninteractive

WORKSHOP="$HOME/workshop"
mkdir "$WORKSHOP"
cd "$WORKSHOP"

./boot-utils/boot-qemu.sh -a x86_64 --smp 2 -k builds/linux --shell
