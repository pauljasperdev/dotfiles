#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}

if [ "$(uname -s)" != "Darwin" ]; then
  log "Not macOS (Darwin)."
  exit 1
fi

# 0) Install Homebrew + everything from Brewfile
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found; installing"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ensure `brew` is available in this non-interactive script
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

log "Running brew bundle"
brew bundle --file "$HOME/.bootstrap.Brewfile"

npm install -g tree-sitter-cli
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh


log "Done"
