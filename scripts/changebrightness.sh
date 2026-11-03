#!/usr/bin/env bash
set -euo pipefail

# brightnessctl -m prints: device,class,value,percent%,max
read -ra brightness_data <<< "$(brightnessctl -m "$@" | tr "," " ")"
brightness_percentage=${brightness_data[3]/"%"/""}
brightness_value=${brightness_data[2]}

device_full=${brightness_data[0]}
device=${device_full##*::}

notify-send \
    -a "brightness" \
    -u low \
    -r "9993" \
    -h int:value:"$brightness_percentage" \
    -i "brightness-${1:-set}" \
    "Brightness ($device): ${brightness_percentage}% (${brightness_value})" \
    -t 2000
