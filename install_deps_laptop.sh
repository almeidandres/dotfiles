#!/bin/bash

set -euo pipefail

sudo dnf install -y subversion xclip

if [[ ! -d "$HOME/.nvm" ]]; then
    export PROFILE=/dev/null
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    unset PROFILE
fi

if ! command -v pnpm >/dev/null 2>&1; then
    curl -fsSL https://get.pnpm.io/install.sh | env ENV=/dev/null sh -
fi

if ! command -v pipx >/dev/null 2>&1; then
    pip3 install --user pipx
fi

if ! command -v deno >/dev/null 2>&1; then
    curl -fsSL https://deno.land/install.sh | sh
fi

echo "Laptop dependencies installed successfully!"

