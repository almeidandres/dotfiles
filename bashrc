# Bash config (interactive only)
case $- in
*i*) ;;
*) return ;;
esac

# History
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# Options
shopt -s checkwinsize

# Completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Shared paths
[ -f "$HOME/.shared_paths.sh" ] && source "$HOME/.shared_paths.sh"
