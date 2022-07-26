#!/bin/bash
set -eu

export LANG=C
export DEBIAN_FRONTEND=noninteractive

WORKSHOP="$HOME/workshop"
cd "$WORKSHOP"
mkdir builds

# Start phase 1 source downloads in background...
(
 # Start fetch of Kees's Linux tree with workshop-specific changes, 200MB
 echo "Cloning Kees's Linux tree..."
 test -d linux-kees || git clone -q --depth 4 --single-branch --branch workshop https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git linux-kees
 # Get QEMU Linux booting tools from the ClangBuiltLinux project.
 echo "Cloning ClangBuiltLinux's qemu tools..."
 test -d boot-utils || git clone -q https://github.com/ClangBuiltLinux/boot-utils
) &

./install-packages.sh

echo "Turning hyperthreading back on..."
./enable-ht.sh

# Wait for initial download to finish, if it hasn't already.
echo "Waiting for initial git clones to finish ..."
wait

# Start full clones in the background...
(
 # Keep clones offset if we all do it at the same time...
 #sleep $(( $RANDOM % 300 ))
 echo "Cloning LLVM tree..."
 test -d llvm-project || git clone -q https://github.com/llvm/llvm-project.git
 # Pick a SHA that seems to build correctly...
 cd llvm-project && git checkout 12fbd2d377e396ad61bce56d71c98a1eb1bebfa9 -b working && cd ..
 echo "Done with LLVM clone. Waiting for Linux build to finish ..."
) &

# Build Kees's patched linux kernel ...
mkdir -p builds/linux
./prepare-linux.sh
time ./make-linux.sh

echo ""
echo "Okay, Linux has been built! Try ./boot-linux.sh in another shell."
echo ""
echo "Now waiting for LLVM clone to finish ..."
wait

(
 echo "Cloning Linus's Linux tree..."
 test -d linux || git clone -q https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
) &

echo "Building latest LLVM..."
time ./make-llvm.sh

# Wait for Linus's tree to finish cloning... should be done after an LLVM build.
wait
