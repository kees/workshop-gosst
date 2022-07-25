#!/bin/bash
set -eu

SRC="${1:-linux-kees}"
cd $SRC

BUILD=../builds/linux
mkdir -p $BUILD

MAKE="make LLVM=1 O=$BUILD -j$(getconf _NPROCESSORS_ONLN)"

$MAKE defconfig kvm_guest.config
./scripts/config --file $BUILD/.config \
	-e SLAB_FREELIST_RANDOM \
	-e SLAB_FREELIST_HARDENED \
	-e HARDENED_USERCOPY \
	-e FORTIFY_SOURCE \
	-e PVPANIC \
	-e WORKSHOP \
	#
