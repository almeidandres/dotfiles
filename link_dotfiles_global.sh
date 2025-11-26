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

# Ask user which git configs to link
echo "Which git configs would you like to link?"
echo "  1) Personal only (Panda)"
echo "  2) Company only (Hexaly)"
echo "  3) Company with personal exception (Hexaly + Panda via includeIf)"
read -p "Enter your choice (1-3): " git_choice

case "$git_choice" in
    1)
        if [[ -f "$DOTFILES_DIR/gitconfig-panda" ]]; then
            create_symlink "$DOTFILES_DIR/gitconfig-panda" "$HOME/.gitconfig"
        fi
        ;;
    2)
        if [[ -f "$DOTFILES_DIR/gitconfig-hexaly" ]]; then
            create_symlink "$DOTFILES_DIR/gitconfig-hexaly" "$HOME/.gitconfig"
        fi
        ;;
    3)
        if [[ -f "$DOTFILES_DIR/gitconfig" ]]; then
            create_symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
        fi
        if [[ -f "$DOTFILES_DIR/gitconfig-panda" ]]; then
            create_symlink "$DOTFILES_DIR/gitconfig-panda" "$HOME/.gitconfig-panda"
        fi
        ;;
    *)
        echo "Invalid choice. Skipping git config linking."
        ;;
esac

echo "Global dotfiles linked successfully!"

