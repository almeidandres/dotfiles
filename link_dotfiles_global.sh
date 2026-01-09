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

create_symlink "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
create_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/shared_paths.sh" "$HOME/.shared_paths.sh"

# Link git configs for company with personal exception
echo "Setting up git configs for company with personal exception..."
if [[ -f "$DOTFILES_DIR/gitconfig" ]]; then
    create_symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
fi
if [[ -f "$DOTFILES_DIR/gitconfig-hexaly" ]]; then
    create_symlink "$DOTFILES_DIR/gitconfig-hexaly" "$HOME/.gitconfig-hexaly"
fi
if [[ -f "$DOTFILES_DIR/gitconfig-panda" ]]; then
    create_symlink "$DOTFILES_DIR/gitconfig-panda" "$HOME/.gitconfig-panda"
fi

echo "Global dotfiles linked successfully!"

