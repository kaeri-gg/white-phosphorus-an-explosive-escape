#!/usr/bin/env bash
# Compare the local Godot editor with the version pinned in .godot-version.
# Usage: tools/check_godot_version.sh [path-to-godot]
# Exit 0 = match (or Godot not found), 1 = mismatch.
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0"/..)" || exit 2
pin=$(tr -d '[:space:]' < .godot-version)           # e.g. 4.6-stable
want=${pin%%-*}                                       # 4.6 or 4.6.1

bin=${1:-${GODOT:-}}
if [ -z "$bin" ]; then
  for c in godot godot4 /Applications/Godot.app/Contents/MacOS/Godot "$HOME/godot/godot"; do
    command -v "$c" >/dev/null 2>&1 && bin=$c && break
  done
fi
[ -z "$bin" ] && { echo "godot binary not found on PATH; skipping version check (set GODOT=...)"; exit 0; }

have=$("$bin" --version 2>/dev/null | head -1)        # e.g. 4.6.stable.official.abc123
have_mm=$(echo "$have" | cut -d. -f1-2)
want_mm=$(echo "$want" | cut -d. -f1-2)
if [ "$have_mm" != "$want_mm" ]; then
  echo "Godot version mismatch: editor is $have, project pins $pin."
  echo "Opening/saving with a different minor version rewrites .import/.tscn/project.godot."
  echo "Either install $pin, or upgrade the project (see UPGRADING_GODOT.txt)."
  exit 1
fi
echo "Godot $have matches pin $pin."
