#!/usr/bin/env bash

# Usage: screenshot.sh [region|full|window]
# Captures screenshot to clipboard via grim + slurp + wl-copy

mode="${1:-region}"

case "$mode" in
    region)
        geometry=$(slurp 2>/dev/null) || exit 0
        grim -g "$geometry" - | wl-copy
        ;;
    full)
        grim - | wl-copy
        ;;
    window)
        geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$geometry" - | wl-copy
        ;;
esac

notify-send -t 2000 "Screenshot" "Copied to clipboard" 2>/dev/null
