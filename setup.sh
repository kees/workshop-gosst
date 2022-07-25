#!/bin/bash
set -eu
set -x

export LANG=C
export DEBIAN_FRONTEND=noninteractive

WORKSHOP="$HOME/workshop"
cd "$WORKSHOP"

# Refresh the package lists.
sudo apt-get update

# Install git first, to start repo cloning.
sudo apt-get install -y git

# Start phase 1 source downloads in background...
(
 # Start fetch of Kees's Linux tree with workshop-specific changes, 200MB
 git clone --depth 4 --single-branch --branch workshop https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git linux-kees
 # Get QEMU Linux booting tools from the ClangBuiltLinux project.
 git clone -q https://github.com/ClangBuiltLinux/boot-utils
) &

./install-packages.sh

# Wait for initial download to finish, if it hasn't already.
echo "Waiting for initial git clones to finish ..."
wait

# Start full clones in the background after up to 5 minutes so we don't all
# slam kernel.org and github...
(
 sleep $(( $RANDOM % 300 ))
 git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git &
 git clone https://github.com/llvm/llvm-project.git
 ./make-llvm.sh
 echo "Fresh LLVM is finished building."
 # Wait for Linus's tree to finish cloning, if it is somehow not already done.
 wait
) &

# Build Kees's patched linux kernel ...
mkdir -p builds/linux
./prepare-linux.sh
./make-linux.sh

echo "Okay, Linux has been built! Try ./boot-linux.sh in another shell."
echo ""
echo "Now waiting for latest LLVM to finish building..."
wait