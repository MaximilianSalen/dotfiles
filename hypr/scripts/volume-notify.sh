#!/bin/bash
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
muted=$(echo "$vol" | grep -c MUTED)
level=$(echo "$vol" | awk '{print int($2 * 100)}')

if [ "$muted" -eq 1 ]; then
    echo 0 > /tmp/wobpipe
else
    echo "$level" > /tmp/wobpipe
fi
