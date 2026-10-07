# Environment loaded for every Zsh process. Keep fast and portable.
export EDITOR="nvim"
export VISUAL="$EDITOR"
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"

typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$BUN_INSTALL/bin"
    "$PNPM_HOME"
    $path
)
export PATH
