# Dotfiles Repository

This is maxi's personal dotfiles repo for an Ubuntu 24.04 (Noble) system running Hyprland on Wayland.

## System Profile

- **OS**: Ubuntu 24.04.4 LTS (x86_64, kernel 6.14)
- **WM**: Hyprland (Wayland)
- **Shell**: zsh (with starship prompt)
- **Terminal**: kitty
- **Editor**: neovim
- **Multiplexer**: tmux
- **Bar**: waybar
- **Launcher**: wofi
- **Notifications**: swaync
- **Logout**: wlogout

## Managed Dotfiles

The following config files/directories should be tracked in this repo:

- `zsh/` — ~/.zshrc and related zsh config
- `tmux/` — ~/.tmux.conf
- `nvim/` — ~/.config/nvim/
- `kitty/` — ~/.config/kitty/
- `hypr/` — ~/.config/hypr/
- `waybar/` — ~/.config/waybar/
- `starship/` — ~/.config/starship.toml
- `wofi/` — ~/.config/wofi/
- `swaync/` — ~/.config/swaync/
- `wlogout/` — ~/.config/wlogout/
- `git/` — ~/.gitconfig
- `ssh/` — ~/.ssh/config (no keys!)

## Conventions

- Each tool gets its own directory in this repo (e.g., `nvim/`, `kitty/`)
- Use a `install.sh` script (or GNU Stow) for symlinking configs to their target locations
- **Never** commit secrets, SSH keys, API tokens, or credentials
- Comments in config files should explain *why*, not *what*
- Keep configs modular — prefer sourcing/importing smaller files over monolithic configs

## When Editing Configs

- Always read the existing config before modifying it
- Preserve the user's existing keybindings and customizations
- Test syntax where possible (e.g., `nvim --headless` for neovim, `hyprctl reload` for hypr)
- When adding features, add them alongside existing config, don't reorganize unless asked
