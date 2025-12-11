# Repository Guidelines

## Project Structure & Scripts
- Core scripts live in the repository root: `bump-gaps.sh` adjusts Hyprland inner/outer gaps by deltas; `toggle-gaps.sh` toggles a “no gaps” mode via a flag file in `XDG_RUNTIME_DIR`; `bindings.conf` lists sample Hyprland keybinds pointing to these scripts.
- Install scripts to your Hyprland config (e.g., `~/.config/hypr/scripts/`) and update paths in `bindings.conf` if you place them elsewhere.
- No vendored assets or tests are present; keep additions small and self-contained.

## Build, Test, and Development Commands
- Run scripts directly: `./toggle-gaps.sh` or `./bump-gaps.sh in + 2`. They expect `hyprctl` to be available in PATH and a running Hyprland session.
- Optional linting: `shellcheck bump-gaps.sh toggle-gaps.sh` to catch shell pitfalls.
- Reload bindings after edits: `hyprctl reload` once updated scripts are in place.

## Coding Style & Naming Conventions
- Bash-first: start new scripts with `#!/usr/bin/env bash`, validate inputs early, and favor readable conditionals over dense one-liners.
- Use uppercase for constants (e.g., `FLAG_FILE`, `MULTIPLIER`) and lowercase for local temporaries.
- Prefer plain `echo`/`printf` for user-facing output and `>&2` for errors; keep comments brief and purposeful above non-obvious logic.

## Testing Guidelines
- No automated suite; sanity-test interactively in a Hyprland session:
  - Toggle flow: run `./toggle-gaps.sh` twice to confirm gaps and visuals (borders/shadows) flip as expected.
  - Gap bumps: `./bump-gaps.sh out + 4` then `./bump-gaps.sh out - 4` and confirm values via `hyprctl getoption general:gaps_out`.
- If adding new scripts, document a minimal manual test recipe alongside them.

## Commit & Pull Request Guidelines
- Commit messages: short, imperative, and scoped (e.g., “Add outer gap decrement guard”); group related script changes in one commit.
- PRs should note behavior changes, manual test steps performed, and any Hyprland version assumptions. Include updated `bindings.conf` snippets if usage changes.
