#!/usr/bin/env bash

# Usage:
#   bump-gaps.sh in  + [step]
#   bump-gaps.sh in  - [step]
#   bump-gaps.sh out + [step]
#   bump-gaps.sh out - [step]
#
# Default step is 1 if not provided; bumps to gaps_out are multiplied by 2.

TARGET="$1"        # in | out
DIR="$2"           # + | -
STEP="${3:-1}"     # default 1 if omitted
MULTIPLIER=1       # multiplier for gaps_out

# --- Validate args --------------------------------------------------------

case "$TARGET" in
  in|out) ;;
  *)
    echo "Target must be 'in' or 'out'" >&2
    exit 1
    ;;
esac

case "$DIR" in
  +|-) ;;
  *)
    echo "Direction must be '+' or '-'" >&2
    exit 1
    ;;
esac

# STEP must be a positive integer
if ! [[ "$STEP" =~ ^[0-9]+$ ]] || [ "$STEP" -le 0 ]; then
  echo "Step must be a positive integer" >&2
  exit 1
fi

if [ "$TARGET" = "out" ]; then
  MULTIPLIER=2
fi

# Signed delta
if [ "$DIR" = "+" ]; then
  DELTA=$(( STEP * MULTIPLIER ))
else
  DELTA=$(( -STEP * MULTIPLIER ))
fi

OPT="general:gaps_$TARGET"

# --- Compute new values and apply -----------------------------------------

NEW_VALUE=$(
  DELTA="$DELTA" OPT="$OPT" python3 <<'PY' 2>/dev/null
import json, re, subprocess, os, sys

opt = os.environ["OPT"]
delta = int(os.environ["DELTA"])

def parse_json():
    try:
        out = subprocess.check_output(["hyprctl", "-j", "getoption", opt], text=True, stderr=subprocess.DEVNULL)
        data = json.loads(out)
    except Exception:
        return None

    nums = []
    def collect(obj):
        nonlocal nums
        if isinstance(obj, dict):
            # Prefer explicit custom vec (e.g., "1 1 1 1"), then int fallback.
            if "custom" in obj:
                found = re.findall(r'-?\d+', str(obj["custom"]))
                if found:
                    nums[:] = [int(x) for x in found]
                    return
            if "int" in obj:
                val = obj["int"]
                if isinstance(val, (int, float)):
                    nums[:] = [int(val)]
                    return
                if isinstance(val, str) and val.lstrip("-").isdigit():
                    nums[:] = [int(val)]
                    return
            for v in obj.values():
                if nums:
                    return
                collect(v)
        elif isinstance(obj, list):
            for v in obj:
                if nums:
                    return
                collect(v)
    collect(data)
    return nums or None

def parse_plain():
    try:
        out = subprocess.check_output(["hyprctl", "getoption", opt], text=True, stderr=subprocess.DEVNULL)
    except Exception:
        return None
    found = re.findall(r'-?\d+', out)
    if found:
        return [int(x) for x in found]
    return None

nums = parse_json() or parse_plain() or [0]
new = [max(0, n + delta) for n in nums]
print(" ".join(str(x) for x in new))
PY
)

hyprctl keyword "$OPT" "$NEW_VALUE" >/dev/null
