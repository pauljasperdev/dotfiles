#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME"

if [[ "$SRC_DIR" == "$DEST_DIR" ]]; then
  printf "Refusing to run: source and destination are both %s\n" "$DEST_DIR" >&2
  printf "Run this script from the cloned repo directory (e.g. ~/.dotfiles).\n" >&2
  exit 1
fi

if [[ ! -d "$SRC_DIR/.git" ]]; then
  printf "Refusing to run: %s does not look like a git clone (.git missing)\n" "$SRC_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_DIR/.config"

# 1) Merge XDG config into ~/.config (and remove sources)
rsync -a \
  --remove-source-files \
  --exclude ".git/" \
  --exclude ".DS_Store" \
  "$SRC_DIR/.config/" \
  "$DEST_DIR/.config/"

# 2) Move top-level dotfiles into ~/
rsync -a \
  --remove-source-files \
  --exclude ".git/" \
  --exclude ".config/" \
  --exclude ".DS_Store" \
  "$SRC_DIR/" \
  "$DEST_DIR/"

# 3) Prune empty directories left behind (but keep the repo dir)
find "$SRC_DIR" -type d -empty -not -path "$SRC_DIR" -print0 | xargs -0 rmdir 2>/dev/null || true

printf "Moved dotfiles into %s (kept %s/.git)\n" "$DEST_DIR" "$SRC_DIR"
