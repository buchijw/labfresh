#!/bin/bash

set -eo pipefail

# Check if the script is being run as normal user
if [ $(id -u) -eq 0 ]; then
    echo "This script must be run as normal user."
    exit 1
fi

# apt update
echo "============================================"
echo "Updating apt..."
echo "============================================"
sudo apt-get update

# # Configure docker CE
# echo "============================================"
# echo "Configuring Docker CE..."
# echo "============================================"
# sudo groupadd docker
# sudo usermod -aG docker $USER
# newgrp docker

# echo "Testing Docker CE non-root access..."
# docker run hello-world

# Configure tailscale
echo "============================================"
echo "Configuring Tailscale..."
echo "============================================"
sudo tailscale up --ssh

# Configure fish
echo "============================================"
echo "Configuring fish..."
echo "============================================"
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)

# Configure starship
echo "============================================"
echo "Configuring starship..."
echo "============================================"
mkdir -p ~/.config && touch ~/.config/starship.toml
starship preset gruvbox-rainbow -o ~/.config/starship.toml
awk '
  BEGIN { in_block=0 }
  /^\[conda\]/ { print; in_block=1; next }
  in_block && /^\[/ { if (!seen) print "ignore_base = false"; in_block=0 }
  in_block && /ignore_base/ { seen=1 }
  { print }
  END { if (in_block && !seen) print "ignore_base = false" }
' ~/.config/starship.toml > ~/.config/starship.toml.tmp && mv ~/.config/starship.toml.tmp ~/.config/starship.toml

grep -qxF 'starship init fish | source' ~/.config/fish/config.fish || echo 'starship init fish | source' >> ~/.config/fish/config.fish

# Configure kitty
echo "============================================"
echo "Configuring kitty..."
echo "============================================"
mkdir -p ~/.config/kitty
cp ./dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp ./dotfiles/kitty/current-theme.conf ~/.config/kitty/current-theme.conf

# Configure pixi
echo "============================================"
echo "Configuring pixi..."
echo "============================================"
grep -qxF "fish_add_path $HOME/.pixi/bin" ~/.config/fish/config.fish || echo "fish_add_path $HOME/.pixi/bin" >> ~/.config/fish/config.fish

# Configure conky
echo "============================================"
echo "Configuring conky..."
echo "============================================"
mkdir -p ~/.config/conky
cp ./dotfiles/conky/conky_users.sh ~/.config/conky/conky_users.sh
chmod +x ~/.config/conky/conky_users.sh
cp ./dotfiles/conky/conky.conf ~/.config/conky/conky.conf

echo "Please add 'conky -c ~/.config/conky/conky.conf' to run on startup"

echo "Please reboot the machine"

exit 0
