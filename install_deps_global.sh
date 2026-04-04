#!/bin/bash

set -euo pipefail

# Base packages
sudo dnf install -y curl wget git zsh neovim fastfetch
sudo dnf copr enable -y alternateved/eza
sudo dnf install -y eza

# Docker (add repo if missing)
if ! command -v docker &> /dev/null; then
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker "$USER"
fi

# OpenCode (PATH is set in ~/.zshrc)
if [[ ! -x "${HOME}/.opencode/bin/opencode" ]]; then
    curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
fi

echo "Global dependencies installed successfully!"

