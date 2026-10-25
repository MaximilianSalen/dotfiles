#!/usr/bin/env bash
# Desktop look: GTK theme, icons, cursor, font and dark mode. Run after install.sh.
# Theme and cursor come from their upstream releases; icons and font from Ubuntu's archive.
set -euo pipefail

GTK_THEME='catppuccin-mocha-flamingo-standard+default'
GTK_URL="https://github.com/catppuccin/gtk/releases/download/v1.0.3/${GTK_THEME}.zip"
CURSOR='Bibata-Modern-Ice'
CURSOR_URL="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/${CURSOR}.tar.xz"

if ! dpkg -s papirus-icon-theme fonts-cantarell unzip >/dev/null 2>&1; then
    sudo apt-get install -y papirus-icon-theme fonts-cantarell unzip
fi

if [ ! -d "$HOME/.themes/$GTK_THEME" ]; then
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/theme.zip" "$GTK_URL"
    mkdir -p "$HOME/.themes"
    unzip -q -o "$tmp/theme.zip" -d "$HOME/.themes"
    rm -rf "$tmp"
fi

if [ ! -d "$HOME/.local/share/icons/$CURSOR" ]; then
    mkdir -p "$HOME/.local/share/icons"
    curl -fsSL "$CURSOR_URL" | tar -xJ -C "$HOME/.local/share/icons"
fi

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface font-name 'Cantarell 11'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "Appearance set. Restart Hyprland (or log out and in) so every app picks it up."
