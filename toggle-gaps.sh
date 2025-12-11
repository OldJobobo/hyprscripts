#!/usr/bin/env bash

# A simple flag file to remember "no gaps" mode
FLAG_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_nogaps.flag"

if ! command -v hyprctl >/dev/null 2>&1; then
    echo "hyprctl is required (Hyprland tools not found)" >&2
    exit 1
fi

if ! hyprctl -j monitors >/dev/null 2>&1; then
    echo "hyprctl is not responding (is Hyprland running?)" >&2
    exit 1
fi

if [ -f "$FLAG_FILE" ]; then
    # Currently in "no gaps" mode -> restore theme
    rm -f "$FLAG_FILE"
    hyprctl reload
else
    # Currently in normal/theme mode -> kill gaps and set flag
    touch "$FLAG_FILE"
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword general:border_size 2
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword decoration:rounding 0
fi
