# Dotfiles

Personal dotfiles for a Hyprland desktop on Ubuntu 24.04 (Noble).

![Hyprland](https://img.shields.io/badge/WM-Hyprland-blue)
![Ubuntu](https://img.shields.io/badge/OS-Ubuntu%2024.04-orange)
![Wayland](https://img.shields.io/badge/Display-Wayland-yellow)

## What's included

| Module | Config for | Target location |
|--------|-----------|-----------------|
| `hypr` | Hyprland, hyprlock, hypridle, hyprpaper | `~/.config/hypr/` |
| `waybar` | Status bar | `~/.config/waybar/` |
| `wofi` | App launcher | `~/.config/wofi/` |
| `swaync` | Notifications | `~/.config/swaync/` |
| `wlogout` | Logout menu | `~/.config/wlogout/` |
| `kitty` | Terminal emulator | `~/.config/kitty/` |
| `nvim` | Neovim (kickstart-based) | `~/.config/nvim/` |
| `tmux` | Terminal multiplexer | `~/.tmux.conf` |
| `zsh` | Shell config | `~/.zshrc` |
| `starship` | Shell prompt | `~/.config/starship.toml` |
| `ssh` | SSH client config | `~/.ssh/config` |

## Full Hyprland setup (from scratch)

If you're on a fresh Ubuntu 24.04 GNOME install and want the complete Hyprland desktop:

```bash
git clone git@github.com:MaximilianSalen/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup-hyprland.sh
```

This script will:
1. Add the Hyprland PPA
2. Install all required packages (Hyprland, waybar, wofi, swaync, wlogout, kitty, etc.)
3. Build mpvpaper from source (video wallpapers)
4. Install FiraCode Nerd Font and Catppuccin cursor theme
5. Symlink the Hyprland-related configs
6. Create `~/.config/hypr/local.conf` for your machine-specific settings

After it finishes, edit `~/.config/hypr/local.conf` to match your hardware, log out of GNOME, select **Hyprland** on the login screen, and log in.

## Picking only what you want

You don't have to use everything. The setup has two layers:

### 1. Install dependencies (packages, fonts, cursors)

Run `setup-hyprland.sh` once to get all the system packages. This is needed regardless of which configs you use.

### 2. Link only the configs you want

```bash
# Just the essentials
./install.sh hypr waybar wofi

# Add notifications and logout screen
./install.sh hypr waybar wofi swaync wlogout

# Non-Hyprland stuff works too
./install.sh kitty nvim tmux zsh starship

# Everything
./install.sh
```

Each module is independent — install as many or as few as you like.

## Machine-specific config

Hardware-specific settings live in `~/.config/hypr/local.conf` (gitignored). A template is provided at `hypr/local.conf.example`:

```conf
# Primary monitor (find yours with: hyprctl monitors | grep Monitor)
$primary_monitor = eDP-1

# Keyboard layout (us, se, de, fr, etc.) — overrides the default (se)
input:kb_layout = us

# VPN name for the waybar toggle (leave empty to disable)
$vpn_name =
```

This file is created automatically by `setup-hyprland.sh` and `install.sh`. Edit it to match your setup.

## Key bindings

| Binding | Action |
|---------|--------|
| `Super + Return` | Terminal (kitty) |
| `Super + Space` | App launcher (wofi) |
| `Super + Q` | Close window |
| `Super + H/J/K/L` | Move focus (vim-style) |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + D` | Show desktop |
| `Super + Escape` | Lock screen |
| `Super + Shift + E` | Logout menu |
| `Super + Shift + V` | Clipboard history |
| `Super + N` | Notification center |
| `Print` | Screenshot (select area) |
| `Shift + Print` | Screenshot (full screen) |

## Theme

- **Color scheme:** Catppuccin Mocha with Flamingo accent
- **Font:** FiraCode Nerd Font
- **Cursors:** Catppuccin Mocha Flamingo
