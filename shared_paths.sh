# ===============================================
# Shared PATH Configuration for Bash and Zsh
# ===============================================

# PNPM Package Manager
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Python tools (pipx)
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$PATH:$HOME/.local/bin" ;;
esac

# Deno Runtime (if installed)
if [ -f "$HOME/.deno/env" ]; then
    . "$HOME/.deno/env"
fi
if [ -f "$HOME/.local/share/bash-completion/completions/deno.bash" ]; then
    source "$HOME/.local/share/bash-completion/completions/deno.bash"
fi