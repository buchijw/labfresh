#!/bin/bash

set -eo pipefail

# starship
echo "============================================"
echo "Installing starship..."
echo "============================================"
curl -sS https://starship.rs/install.sh | sh
