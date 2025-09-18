# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="intheloop"

# Zsh settings
zstyle ':omz:update' mode auto
zstyle ':completion:*' menu select

DISABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

# Plugins
plugins=(
  git
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
)

source $ZSH/oh-my-zsh.sh

# Aliases
alias zshconfig="nvim ~/.zshrc"
alias bashconfig="nvim ~/.bashrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias c="clear"
alias g="git"
alias s="svn"
alias l="ls"
alias la="ls -a"
alias ll="ls -la"
alias vim="nvim"
alias v="nvim"
alias clip="xclip -selection clipboard"

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PNPM setup
export PNPM_HOME="/home/panda/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
