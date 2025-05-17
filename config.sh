#!/bin/bash

set -eo pipefail

# Check if the script is being run as normal user
if [ $(id -u) != 0 ]; then
    echo "This script must be run as normal user."
    exit 1
fi

# apt update
echo "============================================"
echo "Updating apt..."
echo "============================================"
sudo apt-get update

# Configure ibus-bamboo
echo "============================================"
echo "Configuring ibus-bamboo..."
echo "============================================"
env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"

# Configure docker CE
echo "============================================"
echo "Configuring Docker CE..."
echo "============================================"
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

echo "Testing Docker CE non-root access..."
docker run hello-world
