#!/bin/bash

set -euo pipefail

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if source file exists
    [[ -f "$source" ]] || { echo "Error: $source does not exist"; return 1; }
    
    # Remove existing file/symlink and create new one
    rm -f "$target"
    ln -sf "$source" "$target"
}

# Install shell configs
create_symlink "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
create_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

# Setup SSH config if it exists
if [[ -f "$DOTFILES_DIR/ssh-config" ]]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    create_symlink "$DOTFILES_DIR/ssh-config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
fi

# Setup git config if it exists
if [[ -f "$DOTFILES_DIR/gitconfig" ]]; then
    create_symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
fi

echo "Dotfiles installation completed."