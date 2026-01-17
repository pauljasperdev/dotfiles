tap "oven-sh/bun"
tap "opencode-ai/tap"

if RUBY_PLATFORM.include?("darwin")
  tap "homebrew/cask-fonts"
end

# Core tooling
brew "git"
brew "bash"
brew "zsh"
brew "tmux"
brew "neovim"

# Shell + prompt
brew "starship"
brew "lsd"
brew "fzf"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-completions"

# Search / pickers
brew "ripgrep"
brew "fd"

# Neovim formatter deps (conform.nvim)
brew "prettierd"

# Neovim (img-clip.nvim on macOS)
if RUBY_PLATFORM.include?("darwin")
  brew "pngpaste"
end

# JS/tooling
brew "node"
brew "pnpm"
brew "oven-sh/bun/bun"

# Python tooling referenced by your Neovim config
brew "python"
brew "ruff"
brew "uv"

# AI tooling
brew "opencode-ai/tap/opencode"

# Terminal + fonts
if RUBY_PLATFORM.include?("darwin")
  cask "ghostty"
  cask "font-hack-nerd-font"
end

# Containers
if RUBY_PLATFORM.include?("darwin")
  cask "docker-desktop"
end

# Claude Code CLI
cask "claude-code"
