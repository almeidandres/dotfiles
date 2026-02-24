#!/bin/bash

set -euo pipefail

# Packages
sudo dnf install -y subversion xclip pnpm

# NVM (Node version manager)
if [[ ! -d "$HOME/.nvm" ]]; then
    export PROFILE=/dev/null
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    unset PROFILE
fi

echo "Laptop dependencies installed successfully!"

