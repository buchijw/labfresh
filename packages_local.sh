#!/bin/bash

set -eo pipefail

# Check if the script is being run as normal user
if [ $(id -u) -eq 0 ]; then
    echo "This script must be run as normal user."
    exit 1
fi

# miniconda3 https://www.anaconda.com/docs/getting-started/miniconda/install#linux
echo "============================================"
echo "Installing miniconda3..."
echo "============================================"
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

source ~/miniconda3/bin/activate

conda init --all

echo "============================================"
echo "Miniconda3 installation complete!"
echo "============================================"

# Install pymol-open-source in pymol environment
echo "============================================"
echo "Installing pymol-open-source..."
echo "============================================"
conda create -n pymol python=3.12 pymol-open-source -c conda-forge --override-channel -y

# Install pixi
echo "============================================"
echo "Installing pixi..."
echo "============================================"
curl -fsSL https://pixi.sh/install.sh | sh

# Install kitty
echo "============================================"
echo "Installing kitty..."
echo "============================================"
echo "Downloading kitty..."
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    launch=n
echo "Configuring kitty..."
sudo ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten /usr/local/bin
sudo cp ~/.local/kitty.app/share/applications/kitty.desktop /usr/local/share/applications/
sudo cp ~/.local/kitty.app/share/applications/kitty-open.desktop /usr/local/share/applications/
sudo sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" /usr/local/share/applications/kitty*.desktop
sudo sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" /usr/local/share/applications/kitty*.desktop
echo 'kitty.desktop' > ~/.config/xdg-terminals.list

# Install Podman Desktop
echo "============================================"
echo "Installing Podman Desktop..."
echo "============================================"

echo "Adding flathub repo..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Installing Podman Desktop..."
flatpak install --user flathub io.podman_desktop.PodmanDesktop

# Install starship
echo "============================================"
echo "Installing starship..."
echo "============================================"
echo "Install Meslo nerd fonts..."
mkdir -p /tmp/meslo
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O /tmp/Meslo.zip
unzip /tmp/Meslo.zip -d /tmp/meslo && rm /tmp/Meslo.zip
sudo mkdir -p /usr/share/fonts/truetype/meslo
sudo cp /tmp/meslo/*.ttf /usr/share/fonts/truetype/meslo
rm -rf /tmp/meslo
echo "Cache fonts..."
fc-cache -f -v

echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh
