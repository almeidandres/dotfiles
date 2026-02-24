#!/bin/bash

set -euo pipefail

# Base packages
sudo dnf install -y curl wget git zsh neovim fastfetch

# Docker (add repo if missing)
if ! command -v docker &> /dev/null; then
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker "$USER"
fi

echo "Global dependencies installed successfully!"

