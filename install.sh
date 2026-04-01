#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ── helpers ──────────────────────────────────────────────────────────────────

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m::\033[0m %s\n' "$*"; }

backup_and_link() {
    local src="$1" dest="$2"

    # If dest is already a symlink pointing to src, skip
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        ok "Already linked: $dest"
        return
    fi

    # Back up existing file/dir
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        warn "Backing up $dest → $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    ok "Linked: $src → $dest"
}

# ── what to install ──────────────────────────────────────────────────────────

declare -A LINKS=(
    # file in repo                         → target location
    ["$DOTFILES/zsh/.zshrc"]="$HOME/.zshrc"
    ["$DOTFILES/tmux/.tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES/git/.gitconfig"]="$HOME/.gitconfig"
    ["$DOTFILES/ssh/config"]="$HOME/.ssh/config"
    ["$DOTFILES/kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    ["$DOTFILES/starship/starship.toml"]="$HOME/.config/starship.toml"
)

# Directories linked as a whole
declare -A DIR_LINKS=(
    ["$DOTFILES/nvim"]="$HOME/.config/nvim"
    ["$DOTFILES/hypr"]="$HOME/.config/hypr"
    ["$DOTFILES/waybar"]="$HOME/.config/waybar"
    ["$DOTFILES/wofi"]="$HOME/.config/wofi"
    ["$DOTFILES/swaync"]="$HOME/.config/swaync"
    ["$DOTFILES/wlogout"]="$HOME/.config/wlogout"
)

# ── selective install ────────────────────────────────────────────────────────

usage() {
    echo "Usage: $0 [module ...]"
    echo ""
    echo "Modules: zsh tmux git ssh kitty starship nvim hypr waybar wofi swaync wlogout"
    echo ""
    echo "If no modules are specified, all modules are installed."
    exit 0
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

MODULES=("$@")

should_install() {
    local mod="$1"
    # If no modules specified, install everything
    if [ ${#MODULES[@]} -eq 0 ]; then
        return 0
    fi
    for m in "${MODULES[@]}"; do
        if [ "$m" = "$mod" ]; then
            return 0
        fi
    done
    return 1
}

# ── run ──────────────────────────────────────────────────────────────────────

info "Dotfiles installer"
info "Repo: $DOTFILES"
echo ""

# File links
for src in "${!LINKS[@]}"; do
    # Extract module name from path (e.g., zsh, tmux, git, etc.)
    mod=$(echo "$src" | sed "s|$DOTFILES/||" | cut -d/ -f1)
    if should_install "$mod"; then
        backup_and_link "$src" "${LINKS[$src]}"
    fi
done

# Directory links
for src in "${!DIR_LINKS[@]}"; do
    mod=$(basename "$src")
    if should_install "$mod"; then
        backup_and_link "$src" "${DIR_LINKS[$src]}"
    fi
done

# Create local.conf for hypr if it doesn't exist yet
if should_install "hypr" && [ ! -f "$HOME/.config/hypr/local.conf" ]; then
    cp "$DOTFILES/hypr/local.conf.example" "$HOME/.config/hypr/local.conf"
    warn "Created ~/.config/hypr/local.conf from template — edit it for your hardware"
fi

echo ""
if [ -d "$BACKUP_DIR" ]; then
    warn "Backups saved to: $BACKUP_DIR"
fi
ok "Done!"
