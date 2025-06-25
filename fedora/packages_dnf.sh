#!/bin/bash

set -eo pipefail

# Check if the script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# dnf update
echo "============================================"
echo "Updating dnf..."
echo "============================================"
# echo "Installing RPM Fusion..."
# sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# echo "Configuring OpenH264..."
# sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
# echo "Installing RPM Fusion Appstream Data..."
# sudo dnf install rpmfusion-\*-appstream-data
# echo "Installing ffmpeg..."
# sudo dnf swap ffmpeg-free ffmpeg --allowerasing
# echo "Updating dnf..."
sudo dnf check-update
sudo dnf upgrade

# Install app
sudo dnf install -y \
        ca-certificates \
        git \
        htop \
        curl \
        wget \
        aria2 \
        gpg \
        conky \
        podman \
        flatpak \
        screen \
        byobu \
        @development-tools \
        @c-development

# Visual Studio Code
echo "============================================"
echo "Installing Visual Studio Code..."
echo "============================================"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf check-update
sudo dnf install code -y

# Brave Browser
echo "============================================"
echo "Installing Brave Browser..."
echo "============================================"
sudo dnf install dnf-plugins-core -y
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install brave-browser -y

# Install ibus-bamboo
echo "============================================"
echo "Installing ibus-bamboo..."
echo "============================================"
sudo dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:lamlng/Fedora_42/home:lamlng.repo
sudo dnf install ibus-bamboo -y

# fish shell
echo "============================================"
echo "Installing fish shell..."
echo "============================================"
sudo dnf install -y fish

# tailscale
echo "============================================"
echo "Installing tailscale..."
echo "============================================"
curl -fsSL https://tailscale.com/install.sh | sh

# docker
# echo "============================================"
# echo "Installing Docker..."
# echo "============================================"
# install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# apt-get update
# apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Install kanidm
echo "============================================"
echo "Installing kanidm..."
echo "============================================"
sudo dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/network:/idm/Fedora_42/network:idm.repo
sudo dnf check-update
sudo dnf install kanidm-unixd-clients -y

# rustdesk
echo "============================================"
echo "Installing Rustdesk..."
echo "============================================"
wget -qO- --max-redirect=10 https://github.com/rustdesk/rustdesk/releases | grep -wo "https.*x86_64.rpm\|https.*amd64.rpm" | head -n 1 | xargs -I {} wget -O /tmp/rustdesk.rpm {}
sudo dnf install -y /tmp/rustdesk.rpm
rm -rf /tmp/rustdesk.rpm

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
DECRYPTED_KEY=$(echo "$DECRYPT_RUSTDESK" | gpg --batch --yes --passphrase-fd 0 --decrypt ../rdk.asc 2>/dev/null)

if [ -z "$DECRYPTED_KEY" ]; then
  echo "Decryption failed"
  exit 1
fi

# Use the decrypted key (example: configuring a software)
echo "Using decrypted key to configure Rustdesk..."
rustdesk --config "$DECRYPTED_KEY"

systemctl restart rustdesk

echo "Finished installing packages."

exit 0
