#!/bin/bash
set -eu
# Turn on hyperthreading if it was disabled.
for i in /sys/devices/system/cpu/cpu[0-9]*/online; do
	echo 1 | sudo tee $i >/dev/null
done
