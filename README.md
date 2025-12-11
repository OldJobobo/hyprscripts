# Hyprland Gap Helpers

Small utilities for toggling gaps and bumping inner/outer gap values in Hyprland, plus sample keybindings.

## Scripts
- `toggle-gaps.sh` toggles a “no gaps” mode by writing a flag file. It zeroes all gaps, sets borders to 2px, disables rounding and shadows, and on the next toggle reloads Hyprland to restore the currently configured theme values.
- `bump-gaps.sh` increments or decrements `general:gaps_in` or `general:gaps_out` by a delta (outer gaps scale by 2).
- `bindings.conf` contains example Hyprland binds wired to these scripts.

## Installation
1) Place scripts:
   - Copy or symlink `bump-gaps.sh` and `toggle-gaps.sh` to `~/.config/hypr/scripts/`.
   - Ensure they are executable (`chmod +x ~/.config/hypr/scripts/*.sh`).
2) Add keybindings:
   - Copy the contents of `bindings.conf` into your Hyprland keybinds. On Omarchy: `Omarchy menu > Setup > Keybindings`.
   - Or edit `~/.config/hypr/bindings.conf` directly and append the entries.
3) Reload Hyprland: `hyprctl reload`.

## Usage
- Toggle gaps: `~/.config/hypr/scripts/toggle-gaps.sh`.
- Bump inner gaps: `~/.config/hypr/scripts/bump-gaps.sh in + 2` (use `+` or `-`; default step is 1).
- Bump outer gaps: `~/.config/hypr/scripts/bump-gaps.sh out - 2` (outer deltas are doubled).
- Default keybinds from `bindings.conf` (numpad keys are single keys):
  - `SUPER + NUMPAD PLUS`: increase inner gaps; `SUPER + NUMPAD MINUS`: decrease inner gaps.
  - `SUPER + ALT + NUMPAD PLUS`: increase outer gaps; `SUPER + ALT + NUMPAD MINUS`: decrease outer gaps.
  - `SUPER + CTRL + NUMPAD PLUS`: increase both; `SUPER + CTRL + NUMPAD MINUS`: decrease both.

## Requirements
- Hyprland with `hyprctl` available in PATH.
- Bash, standard coreutils.

## Versioning
- Current version: `0.1.0` (see `VERSION`).
