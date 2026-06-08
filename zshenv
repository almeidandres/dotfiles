# Zsh environment loaded for all zsh invocations.
# Keep this file fast and quiet: environment only, no aliases or interactive setup.

export EDITOR="nvim"

# NVM path only. Load nvm.sh from .zshrc for interactive shells when needed.
export NVM_DIR="$HOME/.nvm"

path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}

# Shared paths
[ -f "$HOME/.shared_paths.sh" ] && source "$HOME/.shared_paths.sh"

# Bun
export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"

# Local bin
path_prepend "$HOME/.local/bin"

unfunction path_prepend
