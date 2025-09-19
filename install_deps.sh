#!/bin/bash

set -euo pipefail

# Install basic packages
sudo dnf install -y curl wget git zsh neovim subversion xclip

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-z" ]]; then
    git clone https://github.com/agkozak/zsh-z "$ZSH_CUSTOM/plugins/zsh-z"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]]; then
    git clone https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM/plugins/zsh-autocomplete"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
fi

# Install NVM
if [[ ! -d "$HOME/.nvm" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
fi

# Install PNPM
if ! command -v pnpm >/dev/null 2>&1; then
    # Ensure the pnpm directory and parent directories exist with proper permissions
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.local/share/pnpm"
    chmod 755 "$HOME/.local"
    chmod 755 "$HOME/.local/share"
    chmod 755 "$HOME/.local/share/pnpm"
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Install pipx
if ! command -v pipx >/dev/null 2>&1; then
    # Ensure the local bin directory exists with proper permissions
    mkdir -p "$HOME/.local/bin"
    chmod 755 "$HOME/.local/bin"
    pip3 install --user pipx
    pipx ensurepath
fi

echo "Dependencies installed. Restart terminal or source your RC files."
