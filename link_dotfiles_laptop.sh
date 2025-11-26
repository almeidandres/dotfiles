#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

create_symlink() {
    local source="$1"
    local target="$2"
    
    [[ -f "$source" ]] || { echo "Error: $source does not exist"; return 1; }
    
    rm -f "$target"
    ln -sf "$source" "$target"
}

if [[ -f "$DOTFILES_DIR/ssh-config" ]]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    create_symlink "$DOTFILES_DIR/ssh-config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
fi

echo "Laptop dotfiles linked successfully!"

