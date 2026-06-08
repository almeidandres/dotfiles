# Shared aliases for interactive zsh and Pi's zsh wrapper.
# Keep this file fast and quiet: no completions, prompts, or commands that print.

# Clear function definitions if an older session loaded function-based shortcuts.
unfunction zshconfig bashconfig ohmyzsh v vi vim clip c g s lg ls l la ll 2>/dev/null || true

# Config
alias zshconfig="nvim ~/.zshrc"
alias bashconfig="nvim ~/.bashrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# Editor
alias v="nvim"
alias vi="nvim"
alias vim="command nvim"
alias clip="xclip -selection clipboard"

# General
alias c="clear"
alias g="git"
alias s="svn"
alias lg="lazygit"

# Files
if command -v eza >/dev/null 2>&1; then
    # Pi runs commands with stdin closed; no-arg eza reads stdin and prints
    # nothing. These aliases pass `.` so l/ls/la/ll work in Pi.
    alias eza="command eza ."
    alias ls="command eza --icons --group-directories-first ."
    alias l="command eza --icons --group-directories-first ."
    alias la="command eza -a --icons --group-directories-first ."
    alias ll="command eza -la --icons --group-directories-first ."
else
    alias l="command ls ."
    alias la="command ls -a ."
    alias ll="command ls -la ."
fi
