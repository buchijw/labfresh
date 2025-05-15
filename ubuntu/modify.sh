#!/bin/bash

set -eo pipefail

# xorriso's version must be >= 1.5.7
# which can be manually built from https://www.gnu.org/software/xorriso/

RELEASE=$1

source_iso=./$RELEASE-desktop-amd64.iso
new_iso=./auto-$RELEASE-desktop-amd64.iso
# tmp_dir=./kitchen #
autoinstall_yaml_path=autoinstall.yaml # needs to be in the current directory, or in subdirectories of the current directory

# Remove the existing modified ISO
echo "============================================"
echo "Removing the existing modified ISO..."
echo "============================================"
test -e "${new_iso}" && rm "${new_iso}"

# Generate the modified ISO
echo "============================================"
echo "Generating the modified ISO..."
echo "============================================"
./xorriso \
    -indev "${source_iso}" \
    -outdev "${new_iso}" \
    -add "${autoinstall_yaml_path}" -- \
    -boot_image any replay \
    -compliance no_emul_toc \
    -padding included \
    -stdio_sync off
