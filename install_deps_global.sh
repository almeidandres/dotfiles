#!/bin/bash

set -euo pipefail

sudo dnf install -y curl wget git zsh neovim fastfetch

# Install Docker latest
if ! command -v docker &> /dev/null; then
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker "$USER"
fi

# Install Deno latest
if ! command -v deno &> /dev/null; then
    curl -fsSL https://deno.land/install.sh | sh --no-modify-path
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

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

# Set zsh as default shell if not already
ZSH_PATH="$(command -v zsh)"
if [[ -n "$ZSH_PATH" ]] && ! grep -q "^$ZSH_PATH$" /etc/shells; then
    # Add zsh to /etc/shells if not already there
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi
if [[ -n "$ZSH_PATH" ]] && [[ "$SHELL" != "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"
fi

echo "Global dependencies installed successfully!"

