#!/usr/bin/env sh
set -e

pactl set-sink-volume @DEFAULT_SINK@ "$1"

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n1 | sed 's/%//')

notify-send \
    -a "changevolume" \
    -u low \
    -r "9993" \
    -h int:value:"$volume" \
    -i "volume-$1" "Volume: ${volume}%" \
    -t 2000
