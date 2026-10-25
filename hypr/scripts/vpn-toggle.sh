#!/bin/bash
# Toggle the NetworkManager VPN connection named in $1 ($vpn_name from local.conf)
name="$1"
[ -z "$name" ] && exit 0

if nmcli -t -f NAME connection show --active | grep -Fxq "$name"; then
    nmcli connection down "$name" >/dev/null 2>&1 \
        && notify-send -i network-vpn "VPN" "Disconnected from $name" \
        || notify-send -u critical -i network-error "VPN" "Failed to disconnect $name"
else
    notify-send -i network-vpn "VPN" "Connecting to $name..."
    err=$(nmcli connection up "$name" 2>&1 >/dev/null) \
        && notify-send -i network-vpn "VPN" "Connected to $name" \
        || notify-send -u critical -i network-error "VPN" "Failed to connect: $err"
fi
