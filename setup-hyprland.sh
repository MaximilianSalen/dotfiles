#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# One-shot Hyprland desktop setup for Ubuntu 24.04
# Run from the dotfiles repo:  ./setup-hyprland.sh
# ──────────────────────────────────────────────────────────────
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
err()   { printf '\033[1;31m✗\033[0m %s\n' "$*"; }

# ── Pre-flight checks ────────────────────────────────────────

if ! grep -q 'noble' /etc/os-release 2>/dev/null; then
    warn "This script targets Ubuntu 24.04 (Noble). You appear to be on a different release."
    read -rp "Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
    err "Don't run this as root — sudo will be used where needed."
    exit 1
fi

# ── 1. Add Hyprland PPA ──────────────────────────────────────

info "Adding Hyprland PPA..."
if ! grep -rq 'cppiber/hyprland' /etc/apt/sources.list.d/ 2>/dev/null; then
    sudo add-apt-repository -y ppa:cppiber/hyprland
else
    ok "Hyprland PPA already present"
fi

sudo apt update

# ── 2. Install packages ──────────────────────────────────────

info "Installing Hyprland and desktop packages..."

# Hyprland ecosystem (from PPA)
HYPR_PKGS=(
    hyprland
    hyprlock
    hypridle
    hyprpaper
    hyprpolkitagent
)

# Wayland desktop utilities
DESKTOP_PKGS=(
    waybar
    wofi
    wlogout
    sway-notification-center
    kitty
    wob
    grim
    slurp
    wl-clipboard
    cliphist
    blueman
    pavucontrol
    playerctl
    brightnessctl
    jq
    nautilus
    network-manager-gnome
)

# mpvpaper build dependencies
BUILD_PKGS=(
    meson
    ninja-build
    pkg-config
    libmpv-dev
    libwayland-dev
    wayland-protocols
    libwlr-dev
)

sudo apt install -y "${HYPR_PKGS[@]}" "${DESKTOP_PKGS[@]}" "${BUILD_PKGS[@]}"

# ── 3. Build mpvpaper (not in Ubuntu repos) ──────────────────

if command -v mpvpaper &>/dev/null; then
    ok "mpvpaper already installed"
else
    info "Building mpvpaper from source..."
    TMPDIR="$(mktemp -d)"
    git clone https://github.com/GhostNaN/mpvpaper.git "$TMPDIR/mpvpaper"
    cd "$TMPDIR/mpvpaper"
    meson setup build --prefix=/usr/local
    ninja -C build
    sudo ninja -C build install
    cd "$DOTFILES"
    rm -rf "$TMPDIR"
    ok "mpvpaper installed"
fi

# ── 4. Install FiraCode Nerd Font ────────────────────────────

FONT_DIR="$HOME/.local/share/fonts/FiraCodeNerdFont"
if fc-list | grep -qi 'FiraCode Nerd Font'; then
    ok "FiraCode Nerd Font already installed"
else
    info "Installing FiraCode Nerd Font..."
    mkdir -p "$FONT_DIR"
    TMPDIR="$(mktemp -d)"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz"
    curl -fsSL "$FONT_URL" -o "$TMPDIR/FiraCode.tar.xz"
    tar -xf "$TMPDIR/FiraCode.tar.xz" -C "$FONT_DIR"
    fc-cache -fv "$FONT_DIR" >/dev/null 2>&1
    rm -rf "$TMPDIR"
    ok "FiraCode Nerd Font installed"
fi

# ── 5. Install Catppuccin cursor theme ───────────────────────

CURSOR_DIR="$HOME/.local/share/icons/catppuccin-mocha-flamingo-cursors"
if [ -d "$CURSOR_DIR" ]; then
    ok "Catppuccin cursors already installed"
else
    info "Installing Catppuccin Mocha Flamingo cursors..."
    mkdir -p "$HOME/.local/share/icons"
    TMPDIR="$(mktemp -d)"
    CURSOR_URL="https://github.com/catppuccin/cursors/releases/latest/download/catppuccin-mocha-flamingo-cursors.zip"
    curl -fsSL "$CURSOR_URL" -o "$TMPDIR/cursors.zip"
    unzip -qo "$TMPDIR/cursors.zip" -d "$HOME/.local/share/icons/"
    rm -rf "$TMPDIR"
    ok "Catppuccin cursors installed"
fi

# ── 6. Symlink dotfiles ──────────────────────────────────────

info "Linking Hyprland-related configs..."
"$DOTFILES/install.sh" hypr waybar wofi swaync wlogout kitty

# ── 7. Prompt for local config ───────────────────────────────

LOCAL_CONF="$HOME/.config/hypr/local.conf"
if [ -f "$LOCAL_CONF" ]; then
    echo ""
    info "Your local config ($LOCAL_CONF):"
    cat "$LOCAL_CONF"
    echo ""
    read -rp "Edit it now in \$EDITOR? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        "${EDITOR:-nano}" "$LOCAL_CONF"
    fi
else
    err "local.conf was not created — check install.sh output"
fi

# ── Done ──────────────────────────────────────────────────────

echo ""
ok "Hyprland desktop setup complete!"
echo ""
info "Next steps:"
echo "  1. Review ~/.config/hypr/local.conf (monitor, keyboard layout, VPN)"
echo "     Find your monitor name:  hyprctl monitors | grep Monitor"
echo "     Or after first login:    wlr-randr"
echo "  2. Log out of GNOME"
echo "  3. On the login screen, click the gear icon and select 'Hyprland'"
echo "  4. Log in — waybar, notifications, and wallpapers will start automatically"
echo ""
info "Key bindings cheat sheet:"
echo "  Super + Return      → terminal (kitty)"
echo "  Super + Space       → app launcher (wofi)"
echo "  Super + Q           → close window"
echo "  Super + H/J/K/L     → move focus"
echo "  Super + 1-9         → switch workspace"
echo "  Super + Shift + E   → logout menu"
echo "  Super + Escape      → lock screen"
echo "  Print               → screenshot (select area)"
