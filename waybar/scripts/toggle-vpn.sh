#!/bin/bash
# VPN name from environment, or fall back to parsing local.conf
VPN_NAME="${VPN_NAME:-$(grep '^\$vpn_name' "$HOME/.config/hypr/local.conf" 2>/dev/null | sed 's/.*= *//')}"

if [ -z "$VPN_NAME" ]; then
    notify-send "VPN" "No VPN configured — set \$vpn_name in ~/.config/hypr/local.conf"
    exit 1
fi

if nmcli connection show --active | grep -q "$VPN_NAME"; then
    nmcli connection down "$VPN_NAME"
    notify-send "VPN Disconnected" "$VPN_NAME"
else
    nmcli connection up "$VPN_NAME"
    notify-send "VPN Connected" "$VPN_NAME"
fi
