#!/bin/bash
set -eu

WORKSHOP="$HOME/workshop"
cd "$WORKSHOP"

./enable-ht.sh

SRC="${1:-linux-kees}"
BUILD=../builds/linux

CLANG_DIR="$HOME/workshop/builds/llvm/x86/install/bin"
LLVM=1
# Use the locally build clang if it exists.
if [ -x "$CLANG_DIR"/clang ]; then
	LLVM=$CLANG_DIR/
fi
MAKE="make LLVM=$LLVM O=$BUILD -j$(getconf _NPROCESSORS_ONLN)"
cd $SRC
echo "Building $SRC in $BUILD ..."
$MAKE -s olddefconfig bzImage
