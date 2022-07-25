#!/bin/bash
set -eu

SRC="${1:-linux-kees}"
cd $SRC

BUILD=../builds/linux
mkdir -p $BUILD

MAKE="make LLVM=1 O=$BUILD -j$(getconf _NPROCESSORS_ONLN)"

CONFIGS="defconfig kvm_guest.config workshop.config"
#CONFIGS="$CONFIGS ubsan_bounds.config"

$MAKE $CONFIGS
