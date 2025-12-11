#!/usr/bin/env bash

# A simple flag file to remember "no gaps" mode
FLAG_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_nogaps.flag"

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

