#!/usr/bin/env bash
# Toggle "show desktop" by moving all windows to/from a special workspace

STATE_FILE="/tmp/hypr-show-desktop"

if [ -f "$STATE_FILE" ]; then
    # Restore: move all windows back from the special workspace
    while read -r addr; do
        hyprctl dispatch movetoworkspacesilent "$(cat "$STATE_FILE.ws.$addr")","address:0x$addr"
    done < "$STATE_FILE"
    # Return to the workspace that was active and refocus the previous window
    hyprctl dispatch workspace "$(cat "$STATE_FILE.active")"
    hyprctl dispatch focuswindow "address:0x$(cat "$STATE_FILE.focused")"
    rm -f "$STATE_FILE" "$STATE_FILE".ws.* "$STATE_FILE.active" "$STATE_FILE.focused"
else
    # Save active workspace and focused window
    hyprctl activeworkspace -j | jq -r '.id' > "$STATE_FILE.active"
    hyprctl activewindow -j | jq -r '.address[2:]' > "$STATE_FILE.focused"
    # Save current windows and move them to special:minimize
    hyprctl clients -j | jq -r '.[] | select(.workspace.id >= 0) | "\(.address[2:]) \(.workspace.id)"' | while read -r addr ws; do
        echo "$addr" >> "$STATE_FILE"
        echo "$ws" > "$STATE_FILE.ws.$addr"
        hyprctl dispatch movetoworkspacesilent "special:minimize,address:0x$addr"
    done
fi
