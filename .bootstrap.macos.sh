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

# 1) Ensure Xcode Command Line Tools (required for `make` builds for some Neovim plugins)
if ! xcode-select -p >/dev/null 2>&1; then
  log "Xcode Command Line Tools not found."
  log "Run: xcode-select --install"
fi

# 2) oh-my-zsh (not provided by Homebrew)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh"
  ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "oh-my-zsh already present"
fi

# 4) fzf shell integration
# Your .zshrc sources ~/.fzf.zsh; this file is created by the fzf install script.
FZF_INSTALL="$(brew --prefix)/opt/fzf/install"
if [ -x "$FZF_INSTALL" ]; then
  log "Configuring fzf shell integration"
  "$FZF_INSTALL" --key-bindings --completion --no-update-rc
else
  log "fzf install script not found (is fzf installed via brew?)"
fi

log "Done"
