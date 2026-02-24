# Zsh config

# Environment
export EDITOR="nvim"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="avit"

# Oh My Zsh
zstyle ':omz:update' mode auto
DISABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Plugins (zsh-autocomplete last)
plugins=(
    git
    svn
    zsh-z
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
    zsh-autocomplete
)

# Completions (before Oh My Zsh)
autoload -Uz compinit
compinit

source $ZSH/oh-my-zsh.sh

# Completion behavior
setopt auto_list
setopt auto_menu
unsetopt menu_complete

zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' select-prompt ''
zstyle ':completion:*' menu select=long-list
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# zsh-autocomplete
zstyle ':autocomplete:*' list-prompt ''
zstyle ':autocomplete:*' select-prompt ''

# Aliases
# Config
alias zshconfig="nvim ~/.zshrc"
alias bashconfig="nvim ~/.bashrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# Editor
alias vim="nvim"
alias v="nvim"
alias clip="xclip -selection clipboard"

# General
alias c="clear"
alias g="git"
alias s="svn"

# Files
alias l="ls"
alias la="ls -a"
alias ll="ls -la"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Shared paths
[ -f "$HOME/.shared_paths.sh" ] && source "$HOME/.shared_paths.sh"

# SSH agent
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
    SSH_AGENT_ENV="$HOME/.ssh/agent.env"
    if [ -f "$SSH_AGENT_ENV" ]; then
        . "$SSH_AGENT_ENV" > /dev/null
    fi

    # Start agent if not running
    if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
        eval "$(ssh-agent -s)" > /dev/null
        mkdir -p "$HOME/.ssh"
        echo "export SSH_AGENT_PID=$SSH_AGENT_PID" > "$SSH_AGENT_ENV"
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> "$SSH_AGENT_ENV"
        chmod 600 "$SSH_AGENT_ENV"
    fi

    # Add keys from .ssh
    if [ -d "$HOME/.ssh" ]; then
        for key in "$HOME/.ssh"/*; do
            [ ! -f "$key" ] && continue
            [[ "$key" == *.pub ]] && continue
            [[ "$key" == *config ]] && continue
            [[ "$key" == *known_hosts* ]] && continue
            [[ "$key" == *agent.env ]] && continue
            [[ "$key" == *authorized_keys* ]] && continue

            ssh-add "$key" 2>/dev/null
        done
    fi
fi

# SDKMAN (must be last)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
