#!/bin/bash
level=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')
echo "$level" > /tmp/wobpipe
