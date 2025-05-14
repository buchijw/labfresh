#!/bin/bash

set -euo pipefail

# Check if the script is being run as root
# if [ "$CI" != 'true' ]; then
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi
# fi

# rustdesk
echo "Installing rustdesk..."
wget -qO- --max-redirect=10 https://github.com/rustdesk/rustdesk/releases | grep -wo "https.*x86_64.deb\|https.*amd64.deb" | head -n 1 | xargs -I {} wget -O /tmp/rustdesk.deb {}
apt-get install -y /tmp/rustdesk.deb
rm -rf /tmp/rustdesk.deb

# Prompt user for decryption password securely
echo "Setting up rustdesk..."
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
echo "Using decrypted key to configure software..."
rustdesk --config "$DECRYPTED_KEY"

systemctl restart rustdesk
