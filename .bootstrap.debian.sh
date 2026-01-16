#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}

if [ "$(uname -s)" != "Linux" ]; then
  log "Not Linux."
  exit 1
fi

if [ ! -f /etc/debian_version ]; then
  log "This script targets Debian/Ubuntu (missing /etc/debian_version)."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  log "sudo not found; install it first."
  exit 1
fi

log "Installing apt packages (Homebrew prereqs + Docker)"
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates \
  build-essential \
  procps \
  curl \
  file \
  git \
  unzip \
  fontconfig \
  docker.io \
  docker-compose-v2

# 0) Install Homebrew + everything from Brewfile
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found; installing"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ensure `brew` is available in this non-interactive script
  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
  fi
fi

log "Running brew bundle"
brew bundle --file "$HOME/.bootstrap.Brewfile"

# 1) oh-my-zsh (not provided by Homebrew)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh"
  ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "oh-my-zsh already present"
fi

# 2) fzf shell integration
# Your .zshrc sources ~/.fzf.zsh; this file is created by the fzf install script.
FZF_INSTALL="$(brew --prefix)/opt/fzf/install"
if [ -x "$FZF_INSTALL" ]; then
  log "Configuring fzf shell integration"
  "$FZF_INSTALL" --key-bindings --completion --no-update-rc
else
  log "fzf install script not found (is fzf installed via brew?)"
fi

# 3) Nerd font (Hack Nerd Font) for icons
# Installs into ~/.local/share/fonts
FONT_DIR="$HOME/.local/share/fonts"
if command -v fc-cache >/dev/null 2>&1; then
  mkdir -p "$FONT_DIR"
  if [ ! -f "$FONT_DIR/HackNerdFont-Regular.ttf" ]; then
    log "Installing Hack Nerd Font"
    tmpdir="$(mktemp -d)"
    curl -fsSL -o "$tmpdir/Hack.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
    unzip -o "$tmpdir/Hack.zip" -d "$FONT_DIR" >/dev/null
    rm -rf "$tmpdir"
    fc-cache -f "$FONT_DIR" || true
  fi
fi

# 4) Install local deps for ~/.config/opencode (it has bun.lock)
if [ -d "$HOME/.config/opencode" ]; then
  if command -v bun >/dev/null 2>&1; then
    log "Installing ~/.config/opencode dependencies (bun install)"
    (cd "$HOME/.config/opencode" && bun install)
  else
    log "bun not found; check ~/.bootstrap.brewfile"
  fi
fi

# 5) Docker group permissions
if command -v docker >/dev/null 2>&1; then
  if ! getent group docker >/dev/null 2>&1; then
    log "Creating docker group"
    sudo groupadd docker
  fi
  log "Adding current user to docker group"
  sudo usermod -aG docker "$USER" || true
  log "You may need to log out/in for docker group to apply"
fi

log "Done"
