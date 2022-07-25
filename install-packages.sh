#!/bin/bash
set -eu

export LANG=C
export DEBIAN_FRONTEND=noninteractive

# Refresh the package lists.
sudo apt-get update

# Two phases: one for the Linux build deps, then everything else.
sudo apt build-dep -y $(dpkg -S /boot/vmlinuz-$(uname -r) | cut -d: -f1)

# Report matching package names, if installable.
has_pkg()
{
	apt-cache search '^'"$1"'$' | awk '{print $1}'
}

# Report all package versions
all_ver_pkg()
{
	has_pkg "$1" | cut -d- -f2
}

# Report the highest "-" separated version number
ver_pkg()
{
	all_ver_pkg "$1" | sort -n | tail -n1
}

# Pick first available package name.
pick_pkg()
{
	for pkg in "$@"; do
		has=$(has_pkg "$pkg")
		if [ -n "$has" ]; then
			echo "$has"
			break
		fi
	done
	# If we can't find anything, fail using the "preferred" package.
	echo "$1"
}

# LLVM and Linux want g++-multilib, which conflicts with the GCC
# cross-compilers. Instead, try to figure out what's needed directly
# and filter it out...
build-deps()
{
	apt-get build-dep --just-print "$@" | \
		grep ^Inst | cut -d' ' -f2 | \
		grep -v -- '-multilib$' || true
}

# Start with common build dependencies
PKGS="\
	python3 $(has_pkg python-is-python3) \
	git \
	$(has_pkg coccinelle) \
	devscripts \
	u-boot-tools \
	sparse \
	build-essential \
	libtool-bin \
"

# LLVM build dependencies
LLVMV=$(ver_pkg 'llvm-[0-9]*')
PKGS="$PKGS \
	$(build-deps llvm-$LLVMV) \
	ninja-build \
"

# Linux build dependencies
PKGS="$PKGS $(build-deps $(dpkg -S /boot/vmlinuz-$(uname -r) | cut -d: -f1))"

# Find plugin versions since they're not in the gcc-default alias.
PLUGV=$(ver_pkg 'gcc-.*-plugin-dev')

# Install Distro's native GCC.
PKGS="$PKGS gcc g++ gcc-$PLUGV g++-$PLUGV gcc-$PLUGV-plugin-dev"

# Install Distro's Clang.
PKGS="$PKGS clang lld"

# Install Distro's QEMU.
PKGS="$PKGS qemu-system-x86"

# Installed wanted packages and upgrade anything else that needs it.
#sudo apt-get dist-upgrade -y $PKGS
sudo apt-get install -y $PKGS

# Toss any cruft.
#sudo apt-get autoremove --purge -y
#sudo apt-get clean
