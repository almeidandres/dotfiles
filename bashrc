# Bash config (interactive only)
case $- in
*i*) ;;
*) return ;;
esac

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend checkwinsize

if ! shopt -oq posix; then
    [[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
    [[ -r /etc/bash_completion ]] && . /etc/bash_completion
fi

path_prepend() {
    [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}
path_prepend "$HOME/.local/share/pnpm"
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.local/bin"
export PATH
unset -f path_prepend
