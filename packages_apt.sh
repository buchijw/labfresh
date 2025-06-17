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

# Install app
apt-get install -y \
        apt-transport-https \
        ca-certificates \
        git \
        build-essential \
        htop \
        make \
        curl \
        wget \
        gpg \
        conky-all \
        podman \
        flatpak \
        screen \
        byobu

# Visual Studio Code
echo "============================================"
echo "Installing Visual Studio Code..."
echo "============================================"
wget "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" -O /tmp/code.deb
apt-get install -y /tmp/code.deb
rm -rf /tmp/code.deb

# Microsoft Edge
echo "============================================"
echo "Installing Microsoft Edge..."
echo "============================================"
wget "https://go.microsoft.com/fwlink?linkid=2149051" -O /tmp/edge.deb
apt-get install -y /tmp/edge.deb
rm -rf /tmp/edge.deb

# Install ibus-bamboo
echo "============================================"
echo "Installing ibus-bamboo..."
echo "============================================"
add-apt-repository ppa:bamboo-engine/ibus-bamboo
apt-get update
apt-get install ibus ibus-bamboo --install-recommends -y
# ibus restart
# env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"

# fish shell
echo "============================================"
echo "Installing fish shell..."
echo "============================================"
add-apt-repository ppa:fish-shell/release-4
apt-get update
apt-get install fish -y

# tailscale
echo "============================================"
echo "Installing tailscale..."
echo "============================================"
curl -fsSL https://tailscale.com/install.sh | sh

# docker
echo "============================================"
echo "Installing Docker..."
echo "============================================"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# rustdesk
echo "============================================"
echo "Installing Rustdesk..."
echo "============================================"
wget -qO- --max-redirect=10 https://github.com/rustdesk/rustdesk/releases | grep -wo "https.*x86_64.deb\|https.*amd64.deb" | head -n 1 | xargs -I {} wget -O /tmp/rustdesk.deb {}
apt-get install -y /tmp/rustdesk.deb
rm -rf /tmp/rustdesk.deb

# Prompt user for decryption password securely
echo "Setting up Rustdesk..."
if [ -n "$DECRYPT_RUSTDESK" ]; then
  echo "Using existing decryption password from environment variable"
else
  echo -n "Enter key decryption password: "
  read -s DECRYPT_RUSTDESK
  echo
fi

# Decrypt the file using GPG
DECRYPTED_KEY=$(echo "$DECRYPT_RUSTDESK" | gpg --batch --yes --passphrase-fd 0 --decrypt ./rdk.asc 2>/dev/null)

if [ -z "$DECRYPTED_KEY" ]; then
  echo "Decryption failed"
  exit 1
fi

# Use the decrypted key (example: configuring a software)
echo "Using decrypted key to configure Rustdesk..."
rustdesk --config "$DECRYPTED_KEY"

systemctl restart rustdesk

exit 0
