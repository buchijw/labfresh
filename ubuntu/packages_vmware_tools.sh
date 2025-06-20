#!/bin/bash

set -eo pipefail

# Check if the script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# apt update
echo "============================================"
echo "Updating apt..."
echo "============================================"
apt-get update

echo "============================================"
echo "Installing vmware-tools..."
echo "============================================"
apt-get install -y open-vm-tools

echo "============================================"
echo "Mount vmware shared folder..."
echo "============================================"
sudo mkdir -p /mnt/hgfs
sudo echo "vmhgfs-fuse /mnt/hgfs fuse defaults,allow_other,_netdev 0 0" >> /etc/fstab

echo "Please reboot the machine"

exit 0
