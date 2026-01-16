#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

case "$(uname -s)" in
  Darwin)
    exec "$DOTFILES_DIR/bootstrap.macos.sh" "$@"
    ;;
  Linux)
    if [ -f /etc/debian_version ]; then
      exec "$DOTFILES_DIR/bootstrap.debian.sh" "$@"
    fi
    printf "Unsupported Linux distro (expected Debian/Ubuntu)\n" >&2
    exit 1
    ;;
  *)
    printf "Unsupported OS: %s\n" "$(uname -s)" >&2
    exit 1
    ;;
esac

