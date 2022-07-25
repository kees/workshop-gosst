#!/bin/bash
set -eu

SRC="${1:-linux-kees}"
MAKE="make LLVM=1 O=../builds/linux -j$(getconf _NPROCESSORS_ONLN)"

cd $SRC
$MAKE defconfig kvm_guest.config
./scripts/config \
	-e CONFIG_WORKSHOP=y \
	#
