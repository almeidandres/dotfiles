#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX="backup-$(date +%Y%m%d%H%M%S)"

if [[ "${1:-}" == "--packages" ]]; then
    command -v dnf >/dev/null || { echo "--packages requires dnf" >&2; exit 1; }
    sudo dnf install -y curl gh git neovim zsh
elif [[ $# -ne 0 ]]; then
    echo "usage: $0 [--packages]" >&2
    exit 2
fi

clone_at() {
    local repository="$1" destination="$2" revision="$3"
    if [[ ! -d "$destination/.git" ]]; then
        git clone --filter=blob:none --no-checkout "$repository" "$destination"
    fi
    git -C "$destination" cat-file -e "$revision^{commit}" 2>/dev/null ||
        git -C "$destination" fetch --depth 1 origin "$revision"
    git -C "$destination" checkout --quiet --detach "$revision"
}

clone_at https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" f809d46c10c59b3824c9be6c7ccb46db690cd441
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
clone_at https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 0e810e5afa27acbd074398eefbe28d13005dbc15
clone_at https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 5eb677bb0fa9a3e60f0eff031dc13926e093df92
clone_at https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/zsh-history-substring-search" 87ce96b1862928d84b1afe7c173316614b30e301
clone_at https://github.com/agkozak/zsh-z.git "$ZSH_CUSTOM/plugins/zsh-z" cf9225feebfae55e557e103e95ce20eca5eff270

link_file() {
    local source="$1" target="$2"
    mkdir -p "$(dirname "$target")"
    if [[ -L "$target" && "$(readlink -f "$target")" == "$source" ]]; then
        return
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        mv "$target" "$target.$BACKUP_SUFFIX"
    fi
    ln -s "$source" "$target"
}

chmod 0755 "$ROOT/pi-zsh"
link_file "$ROOT/bashrc" "$HOME/.bashrc"
link_file "$ROOT/zshenv" "$HOME/.zshenv"
link_file "$ROOT/zshrc" "$HOME/.zshrc"
link_file "$ROOT/zsh_aliases.zsh" "$HOME/.config/zsh/aliases.zsh"
link_file "$ROOT/pi-zsh" "$HOME/.local/bin/pi-zsh"
link_file "$ROOT/gitconfig" "$HOME/.gitconfig"
link_file "$ROOT/gitconfig-hexaly" "$HOME/.gitconfig-hexaly"

for obsolete in "$HOME/.shared_paths.sh:$ROOT/shared_paths.sh" "$HOME/.gitconfig-panda:$ROOT/gitconfig-panda"; do
    target="${obsolete%%:*}"
    source="${obsolete#*:}"
    [[ -L "$target" && "$(readlink "$target")" == "$source" ]] && rm "$target"
done

printf 'Dotfiles linked from %s\n' "$ROOT"
