# Bash configuration
# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# Shell options
# Check window size after each command
shopt -s checkwinsize

# Completion & colors
# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Enable color support for ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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
alias l="ls"
alias la="ls -a"
alias ll="ls -la"

# Editor
export EDITOR="nvim"
alias vim="nvim"
alias v="nvim"
alias clip="xclip -selection clipboard"

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

# Python tools (pipx) - only add if not already in PATH
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