#!/usr/bin/env bash

# Usage:
#   bump-gaps.sh in  + [step]
#   bump-gaps.sh in  - [step]
#   bump-gaps.sh out + [step]
#   bump-gaps.sh out - [step]
#
# Default step is 1 if not provided; bumps to gaps_out are multiplied by 2.

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "hyprctl is required (Hyprland tools not found)" >&2
  exit 1
fi

if ! hyprctl -j monitors >/dev/null 2>&1; then
  echo "hyprctl is not responding (is Hyprland running?)" >&2
  exit 1
fi

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

read_nums_json() {
  local out
  out=$(hyprctl -j getoption "$OPT" 2>/dev/null | tr '\n' ' ') || return 1
  [[ -z "$out" ]] && return 1

  if [[ $out =~ \"custom\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  if [[ $out =~ \"int\"[[:space:]]*:[[:space:]]*(-?[0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  return 1
}

read_nums_plain() {
  local out
  out=$(hyprctl getoption "$OPT" 2>/dev/null) || return 1
  echo "$out" | grep -Eo '-?[0-9]+' | paste -sd' ' -
}

NUMS=$(read_nums_json)
if [ -z "$NUMS" ]; then
  NUMS=$(read_nums_plain)
fi
[ -z "$NUMS" ] && NUMS="0"

NEW=()
for n in $NUMS; do
  val=$(( n + DELTA ))
  [ "$val" -lt 0 ] && val=0
  NEW+=( "$val" )
done

NEW_VALUE="${NEW[*]}"

if ! hyprctl keyword "$OPT" "$NEW_VALUE" >/dev/null; then
  echo "Failed to apply $OPT=$NEW_VALUE" >&2
  exit 1
fi
