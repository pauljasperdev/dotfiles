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

log "Installing apt packages"
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  rsync \
  unzip \
  build-essential \
  pkg-config \
  zsh \
  bash \
  tmux \
  neovim \
  ripgrep \
  fzf \
  fd-find \
  nodejs \
  npm \
  python3 \
  python3-pip \
  python3-venv \
  pipx \
  xclip \
  wl-clipboard \
  docker.io \
  docker-compose-plugin

# 0) Ensure ~/.local/bin is on PATH (pipx installs there)
mkdir -p "$HOME/.local/bin"

# 1) Install OpenCode (official installer supports Linux)
if ! command -v opencode >/dev/null 2>&1; then
  log "Installing opencode"
  curl -fsSL https://opencode.ai/install | bash
else
  log "opencode already present"
fi

# 2) Install Claude Code (official installer supports Linux)
if ! command -v claude >/dev/null 2>&1; then
  log "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
else
  log "claude already present"
fi

# 3) Node tooling (needed by prettierd, opencode plugins, etc.)
# Debian/Ubuntu node versions vary; we start with apt's nodejs if present.
if ! command -v node >/dev/null 2>&1; then
  log "node not found after apt install (unexpected)."
else
  if command -v corepack >/dev/null 2>&1; then
    log "Enabling corepack (pnpm)"
    corepack enable || true
    corepack prepare pnpm@latest --activate || true
  fi
fi

# 4) Install pnpm if corepack wasn't available
if ! command -v pnpm >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  log "Installing pnpm via npm"
  sudo npm install -g pnpm
fi

# 5) Install bun (official installer)
if ! command -v bun >/dev/null 2>&1; then
  log "Installing bun"
  curl -fsSL https://bun.sh/install | bash
  # bun installs to ~/.bun/bin
  export PATH="$HOME/.bun/bin:$PATH"
fi

# 6) Neovim formatter deps referenced by your conform.nvim config
# - prettierd: npm package @fsouza/prettierd
# - stylua: install via cargo (Debian package rustc/cargo is good enough)
# - ruff: install via pipx
if command -v npm >/dev/null 2>&1 && ! command -v prettierd >/dev/null 2>&1; then
  log "Installing prettierd"
  sudo npm install -g @fsouza/prettierd
fi

if ! command -v cargo >/dev/null 2>&1; then
  log "Installing cargo (for stylua)"
  sudo apt-get install -y cargo
fi

if command -v cargo >/dev/null 2>&1 && ! command -v stylua >/dev/null 2>&1; then
  log "Installing stylua (cargo)"
  cargo install stylua
fi

if ! command -v ruff >/dev/null 2>&1; then
  log "Installing ruff (pipx)"
  pipx ensurepath || true
  pipx install ruff
fi

# 7) fzf shell integration
# Your .zshrc sources ~/.fzf.zsh. Generate it if fzf supports it.
if command -v fzf >/dev/null 2>&1; then
  if fzf --help 2>/dev/null | rg -q "--zsh"; then
    log "Generating ~/.fzf.zsh"
    fzf --zsh > "$HOME/.fzf.zsh"
  else
    log "fzf --zsh not supported; install fzf from upstream or Homebrew for shell integration"
  fi
fi

# 8) Nerd font (Hack Nerd Font) for icons (Ghostty/Powerline/etc)
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

# 9) oh-my-zsh + tmux TPM
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh (git clone)"
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Installing tmux TPM (git clone)"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 10) Install local deps for ~/.config/opencode (it has bun.lock)
if [ -d "$HOME/.config/opencode" ] && command -v bun >/dev/null 2>&1; then
  log "Installing ~/.config/opencode dependencies (bun install)"
  (cd "$HOME/.config/opencode" && bun install)
fi

# 11) Docker group permissions
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
