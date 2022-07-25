#!/bin/bash
set -eu
set -x

export LANG=C
export DEBIAN_FRONTEND=noninteractive

WORKSHOP="$HOME/workshop"
cd "$WORKSHOP"

# Create a tmpfs for faster writes.
if [ ! -d builds ]; then
	mkdir builds
	sudo mount -t tmpfs -o size=10G none "$WORKSHOP/builds"
	sudo chown $USER builds
fi

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

# Wait for initial download to finish, if it hasn't already.
echo "Waiting for initial git clones to finish ..."
wait

# Start full clones in the background after up to 5 minutes so we don't all
# slam kernel.org and github...
(
 sleep $(( $RANDOM % 300 ))
 echo "Cloning Linus's Linux tree..."
 test -d linux || git clone -q https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git &
 echo "Cloning LLVM tree..."
 test -d llvm-project || git clone -q https://github.com/llvm/llvm-project.git
 # Pick a SHA that seems to build correctly...
 cd llvm-project && git checkout 12fbd2d377e396ad61bce56d71c98a1eb1bebfa9 -b working && cd ..
 # Wait for Linus's tree to finish cloning, if it is somehow not already done.
 wait
) &

# Build Kees's patched linux kernel ...
mkdir -p builds/linux
./prepare-linux.sh
time ./make-linux.sh

echo ""
echo "Okay, Linux has been built! Try ./boot-linux.sh in another shell."
echo ""
echo "Now waiting for latest LLVM to finish cloning..."
wait

echo "Building latest LLVM..."
time ./make-llvm.sh
