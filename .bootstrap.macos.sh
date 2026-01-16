#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

log() {
  printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}

if [ "$(uname -s)" != "Darwin" ]; then
  log "Not macOS (Darwin). Use bootstrap.debian.sh instead."
  exit 1
fi

# 0) Install everything from Brewfile
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found. Install it from https://brew.sh and re-run."
  exit 1
fi

log "Running brew bundle"
brew bundle --file "$DOTFILES_DIR/Brewfile"

# 1) Ensure Xcode Command Line Tools (required for `make` builds for some Neovim plugins)
if ! xcode-select -p >/dev/null 2>&1; then
  log "Xcode Command Line Tools not found."
  log "Run: xcode-select --install"
fi

# 2) oh-my-zsh (not provided by Homebrew)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh (git clone)"
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
  log "oh-my-zsh already present"
fi

# 3) tmux TPM (not provided by Homebrew)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Installing tmux TPM (git clone)"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  log "tmux TPM already present"
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

# 5) Install local deps for ~/.config/opencode (it has bun.lock)
if [ -d "$HOME/.config/opencode" ]; then
  if command -v bun >/dev/null 2>&1; then
    log "Installing ~/.config/opencode dependencies (bun install)"
    (cd "$HOME/.config/opencode" && bun install)
  else
    log "bun not found; check Brewfile install"
  fi
fi

# 6) (Optional) install tmux plugins non-interactively
if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  if command -v tmux >/dev/null 2>&1; then
    log "Installing tmux plugins via TPM"
    "$HOME/.tmux/plugins/tpm/bin/install_plugins"
  else
    log "tmux not found; skipping TPM plugin install"
  fi
fi

log "Done"
