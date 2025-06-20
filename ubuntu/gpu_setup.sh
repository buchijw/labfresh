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

# Choose GPU manufacturer
echo "============================================"
echo "Choose GPU manufacturer:"
echo "============================================"
echo "1. NVIDIA (CUDA Toolkit)"
echo "2. AMD (ROCm)"
read -p "Enter your choice (1 or 2): " choice

if [ $choice -eq 1 ]; then
    echo "============================================"
    echo "Installing NVIDIA CUDA Toolkit..."
    echo "============================================"
    # https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=24.04&target_type=deb_network
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i cuda-keyring_1.1-1_all.deb
    apt-get update
    apt-get -y install cuda
    rm -rf cuda-keyring_1.1-1_all.deb
else
    echo "============================================"
    echo "Installing AMD ROCm..."
    echo "============================================"
    wget -r "https://repo.radeon.com/amdgpu-install/latest/ubuntu/noble/" -A "amdgpu-install*.deb" --no-parent -nd -e robots=off
    mv amdgpu-install*.deb amdgpu-install.deb
    apt-get install -y ./amdgpu-install.deb
    rm -rf amdgpu-install.deb
    amdgpu-install --usecase=graphics,rocm,rocmdev,lrt,openclsdk,hiplibsdk,openmpsdk,mllib,mlsdk
