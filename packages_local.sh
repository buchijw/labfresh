#!/bin/bash

set -eo pipefail

# Check if the script is being run as normal user
if [ $(id -u) != 0 ]; then
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
conda create -n pymol python=3.12 pymol-open-source -c conda-forge --overwrite-channel -y

# Install pixi
echo "============================================"
echo "Installing pixi..."
echo "============================================"
curl -fsSL https://pixi.sh/install.sh | sh

# Install Podman Desktop
echo "============================================"
echo "Installing Podman Desktop..."
echo "============================================"

echo "Adding flathub repo..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Installing Podman Desktop..."
flatpak install --user flathub io.podman_desktop.PodmanDesktop
