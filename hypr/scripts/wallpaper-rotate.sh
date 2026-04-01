#!/usr/bin/env bash
# Rotates wallpapers every 30 minutes using mpvpaper instead of hyprpaper

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
# Auto-detect primary monitor, fallback to eDP-1
MONITOR="${HYPR_MONITOR:-$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].name // empty')}"
MONITOR="${MONITOR:-eDP-1}"
INTERVAL=1800 # 30 minutes

get_random_wallpaper() {
    find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.webp' -o -name '*.mp4' -o -name '*.mkv' -o -name '*.webm' -o -name '*.gif' \) | shuf -n 1
}

set_wallpaper() {
    local wp="$1"
    killall mpvpaper 2>/dev/null
    sleep 0.5
    mpvpaper -o "no-audio loop" "$MONITOR" "$wp" &
    disown
}

CURRENT=""

while true; do
    NEXT="$(get_random_wallpaper)"

    # Skip if same as current or empty
    if [[ -z "$NEXT" || "$NEXT" == "$CURRENT" ]]; then
        sleep "$INTERVAL"
        continue
    fi

    set_wallpaper "$NEXT"

    CURRENT="$NEXT"
    sleep "$INTERVAL"
done
