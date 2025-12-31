# Zsh configuration

# Aliases
# Configuration files
alias zshconfig="nvim ~/.zshrc"
alias bashconfig="nvim ~/.bashrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# General shortcuts
alias c="clear"
alias g="git"
alias s="svn"

# File operations
alias s="svn"
alias l="ls"
alias la="ls -a"
alias ll="ls -la"

# Editor
export EDITOR="nvim"
alias vim="nvim"
alias v="nvim"
alias clip="xclip -selection clipboard"

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="intheloop"

# Zsh settings
zstyle ':omz:update' mode auto
DISABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
LISTMAX=10
setopt auto_list           # List choices on ambiguous completion
setopt auto_menu           # Use menu completion after second consecutive request
setopt menu_complete       # Insert first match immediately, then cycle through others
zstyle ':completion:*' list-prompt ''  # Remove the "more" prompt
zstyle ':completion:*' menu select     # Use menu selection instead
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Plugins
plugins=(
    git
    svn
    zsh-z
    zsh-autocomplete
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
    sudo
    docker
    docker-compose
    copyfile
    copypath
    command-not-found
    colored-man-pages
    extract
    alias-finder
    aliases
    colorize
    history
    vscode
    you-should-use
)

source $ZSH/oh-my-zsh.sh

# SSH Agent setup - always use Linux ssh-agent
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
    SSH_AGENT_ENV="$HOME/.ssh/agent.env"
    if [ -f "$SSH_AGENT_ENV" ]; then
        . "$SSH_AGENT_ENV" > /dev/null
    fi
    
    # Check if agent is still running
    if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
        eval "$(ssh-agent -s)" > /dev/null
        mkdir -p "$HOME/.ssh"
        echo "export SSH_AGENT_PID=$SSH_AGENT_PID" > "$SSH_AGENT_ENV"
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> "$SSH_AGENT_ENV"
        chmod 600 "$SSH_AGENT_ENV"
    fi
    
    # Add all SSH private keys from .ssh folder
    if [ -d "$HOME/.ssh" ]; then
        for key in "$HOME/.ssh"/*; do
            # Skip if not a regular file, or if it's a public key, config, or other non-key files
            [ ! -f "$key" ] && continue
            [[ "$key" == *.pub ]] && continue
            [[ "$key" == *config ]] && continue
            [[ "$key" == *known_hosts* ]] && continue
            [[ "$key" == *agent.env ]] && continue
            [[ "$key" == *authorized_keys* ]] && continue
            
            # Try to add the key (will skip if already loaded or invalid)
            ssh-add "$key" 2>/dev/null
        done
    fi
fi

# Development tools
# Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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

# Add deno completions to search path
if [ -d "$HOME/completions" ]; then
    if [[ ":$FPATH:" != *":$HOME/completions:"* ]]; then
        export FPATH="$HOME/completions:$FPATH"
    fi
fi

# Initialize zsh completions
autoload -Uz compinit
compinit
fi
