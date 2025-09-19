#!/bin/bash

set -euo pipefail

echo "Cleaning up PATH duplicates..."

# Remove auto-generated pnpm configuration from shell files
echo "Removing auto-generated pnpm configuration..."
sed -i '/# pnpm$/,/# pnpm end$/d' "$HOME/.zshrc" 2>/dev/null || true
sed -i '/# pnpm$/,/# pnpm end$/d' "$HOME/.bashrc" 2>/dev/null || true

echo "PATH cleanup complete!"
echo ""
echo "Please restart your terminal or run:"
echo "  source ~/.zshrc    # if using zsh"
echo "  source ~/.bashrc   # if using bash"
echo ""
echo "Your dotfiles now handle PATH management properly to prevent duplicates."
