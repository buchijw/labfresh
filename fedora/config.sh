#!/bin/bash

set -eo pipefail

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Check if the script is being run as normal user
if [ $(id -u) -eq 0 ]; then
    echo "This script must be run as normal user."
    exit 1
fi

# dnf update
echo "============================================"
echo "Updating dnf..."
echo "============================================"
sudo dnf upgrade

# Configure kanidm
echo "============================================"
echo "Configuring kanidm..."
echo "============================================"
sudo semanage permissive -a unconfined_service_t
sudo mkdir -p "/u"
read -p "Enter your IDM URL: " new_url && echo "uri = \"$new_url\"" >> "./kanidm/config"
sudo cp "./kanidm/config" "/etc/kanidm/config"
sudo cp "./kanidm/unixd" "/etc/kanidm/unixd"
sudo chown root:root "/etc/kanidm/config"
sudo chmod 644 "/etc/kanidm/config"
sudo chown root:root "/etc/kanidm/unixd"
sudo chmod 644 "/etc/kanidm/unixd"
sudo mkdir -p /etc/systemd/system/kanidm-unixd-tasks.service.d
sudo cp ./kanidm/override.conf /etc/systemd/system/kanidm-unixd-tasks.service.d/override.conf
sudo chmod 644 /etc/systemd/system/kanidm-unixd-tasks.service.d/override.conf
sudo systemctl enable --now kanidm-unixd
sudo systemctl daemon-reload
kanidm-unix status
sudo cp -a /etc/pam.d /etc/pam.d.backup


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
confirm "Do you want to connect to Tailscale?" && sudo tailscale up --ssh

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
# echo "============================================"
# echo "Configuring kitty..."
# echo "============================================"
# mkdir -p ~/.config/kitty
# cp ./dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

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
cp ../conky/conky_users.sh ~/.config/conky/conky_users.sh
sudo chmod +x ~/.config/conky/conky_users.sh
cp ../conky/conky.conf ~/.config/conky/conky.conf

echo "Please add 'conky -c ~/.config/conky/conky.conf' to run on startup"

echo "Please reboot the machine"

exit 0
