#!/bin/bash
set -eu
set -x

WORKSHOP="$HOME/workshop"
cd "$WORKSHOP"

./boot-utils/boot-qemu.sh -a x86_64 --smp 2 -k builds/linux --shell
