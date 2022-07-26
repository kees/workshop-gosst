#!/bin/bash
set -eu

WORKSHOP="$HOME/workshop"
cd "$WORKSHOP"

./boot-utils/boot-qemu.sh -a x86_64 --smp 2 -k ${1:-builds/linux} --shell
