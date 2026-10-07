# Zsh config
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="avit"

[[ -o interactive ]] || return

zstyle ':omz:update' mode disabled
DISABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
    git
    svn
    sudo
    docker
    docker-compose
    extract
    colored-man-pages
    zsh-z
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
)

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

setopt auto_list auto_menu
unsetopt menu_complete
zstyle ':completion:*' menu select=long-list
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

[[ -r "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -r "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
