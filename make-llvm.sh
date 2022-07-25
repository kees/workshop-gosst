#!/bin/bash
set -eu

NAME=x86

PROJECT="$HOME/workshop/llvm-project/llvm"
BUILD="$HOME/workshop/builds/llvm"

REV=$(cd "$PROJECT" && git rev-parse HEAD)

STAGE3="$BUILD/stage3-$REV"

# Use existing.
STAGE1BIN="/usr/bin"

_CMAKE_COMMON="\
	--log-level=NOTICE \
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_ENABLE_PROJECTS='clang;lld;compiler-rt'	\
	-DLLVM_USE_LINKER=lld			\
	-DCMAKE_C_COMPILER="$STAGE1BIN"/clang      \
	-DCMAKE_CXX_COMPILER="$STAGE1BIN"/clang++  \
	-DCMAKE_RANLIB="$STAGE1BIN"/llvm-ranlib    \
	-DCMAKE_AR="$STAGE1BIN"/llvm-ar            \
"

# Stage 3
echo "Stage 3 ($REV as $NAME)"
cd "$BUILD"

prep=
if [ ! -d "$STAGE3" ]; then
	echo "Building $STAGE3 ..."
	prep=yes
else
	echo "Rebuilding $STAGE3 ..."
	#rm -rf "$STAGE3"
fi
mkdir -p "$STAGE3" && cd "$STAGE3"
if [ -n "$prep" ]; then
	cmake -G Ninja $_CMAKE_COMMON \
		-DCMAKE_INSTALL_PREFIX="$STAGE3/install"	\
		"$PROJECT"
fi
time ninja install
STAGE3BIN="$STAGE3/install/bin"
echo "$STAGE3BIN"

cd "$BUILD"
# Clobber the old one with the new one.
ln -snf $(basename "$STAGE3") "$NAME"
