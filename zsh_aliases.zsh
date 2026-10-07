# Shared aliases for interactive Zsh and Pi.
unalias eza ls l la ll 2>/dev/null || true
unfunction zshconfig bashconfig ohmyzsh v vi vim clip c g s lg ls l la ll eza 2>/dev/null || true

alias zshconfig="nvim ~/.zshrc"
alias bashconfig="nvim ~/.bashrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias v="nvim"
alias vi="nvim"
alias vim="command nvim"
alias c="clear"
alias g="git"
alias s="svn"
alias lg="lazygit"

clip() {
    if command -v wl-copy >/dev/null 2>&1; then
        wl-copy "$@"
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard "$@"
    else
        print -u2 "clip: install wl-clipboard or xclip"
        return 127
    fi
}

[[ -x /opt/hexaly_14_5/bin/hexaly ]] && alias hexaly14="/opt/hexaly_14_5/bin/hexaly"
[[ -x /opt/hexaly_15_0/bin/hexaly ]] && alias hexaly15="/opt/hexaly_15_0/bin/hexaly"

if command -v eza >/dev/null 2>&1; then
    eza() { command eza "${@:-.}"; }
    ls() { command eza --icons --group-directories-first "${@:-.}"; }
    l() { ls "$@"; }
    la() { command eza -a --icons --group-directories-first "${@:-.}"; }
    ll() { command eza -la --icons --group-directories-first "${@:-.}"; }
else
    l() { command ls "${@:-.}"; }
    la() { command ls -a "${@:-.}"; }
    ll() { command ls -la "${@:-.}"; }
fi
