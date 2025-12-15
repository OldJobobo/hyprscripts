#!/usr/bin/env bash
set -euo pipefail

CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"

# If you use a split config, point CONF at the file that actually contains your decoration{} block,
# or change this script to edit that included file instead.

# Read current value (default: 1 if not found)
cur="$(grep -E '^\s*drop_shadow\s*=\s*' "$CONF" | tail -n1 | sed -E 's/.*=\s*([01]).*/\1/;t;d')"
cur="${cur:-1}"

if [[ "$cur" == "1" ]]; then
  new="0"
else
  new="1"
fi

# Update (or insert) drop_shadow within decoration block if present; otherwise, do a simple replace/append.
if grep -qE '^\s*decoration\s*\{' "$CONF"; then
  # Replace last seen drop_shadow assignment anywhere in file (simple + robust)
  if grep -qE '^\s*drop_shadow\s*=\s*[01]\s*$' "$CONF"; then
    sed -i -E "s/^\s*drop_shadow\s*=\s*[01]\s*$/    drop_shadow = $new/" "$CONF"
  else
    # If missing, append near end (safe fallback)
    printf "\n# Added by toggle-shadows\n    drop_shadow = %s\n" "$new" >> "$CONF"
  fi
else
  # No decoration block found; append a minimal one
  cat >>"$CONF" <<EOF

# Added by toggle-shadows
decoration {
  drop_shadow = $new
}
EOF
fi

hyprctl reload >/dev/null

