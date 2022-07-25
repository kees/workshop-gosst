#!/bin/bash
set -eu

SRC="${1:-linux-kees}"
CLANG_DIR="$HOME/workshop/builds/llvm/x86/install/bin"
LLVM=1
# Use the locally build clang if it exists.
if [ -x "$CLANG_DIR"/clang ]; then
	LLVM=$CLANG_DIR/
fi
MAKE="make LLVM=$LLVM O=../builds/linux -j$(getconf _NPROCESSORS_ONLN)"
cd $SRC
$MAKE -s olddefconfig bzImage)