# Dotfiles agent notes

This repo is intended to be cloned to `~/.dotfiles` and then converted into a "bare git-dir" style setup where the working tree is your home directory.

## How it works

- **Initial clone**: You start with a normal clone at `~/.dotfiles`.
- **Move step**: `~/.dotfiles/.bootstrap.move.sh` merges files into `~` and then removes the source files from the clone, leaving only `~/.dotfiles/.git` behind.
- **After move**: The tracked files live in `~` (e.g. `~/.zshrc`, `~/.config/...`). Git metadata remains in `~/.dotfiles/.git`.

A typical git alias used with this layout:

```sh
alias dotfiles='git --git-dir="$HOME/.dotfiles/.git" --work-tree="$HOME"'
```

## Install / apply dotfiles

```sh
git clone https://github.com/pauljasperdev/dotfiles ~/.dotfiles
~/.dotfiles/.bootstrap.move.sh
```

Notes:
- This **overwrites** top-level files like `~/.zshrc` and `~/.tmux.conf`.
- This **merges** directories under `~/.config/`.
- After the move, `~/.dotfiles/` should contain only `.git/`.

## Bootstrap (dependencies)

Run the OS-specific bootstrap script after the move:

```sh
# macOS
~/.bootstrap.macos.sh

# Debian/Ubuntu
~/.bootstrap.debian.sh
```

Notes:
- All cross-platform dependencies live in `~/.bootstrap.brewfile` and are installed via `brew bundle`.
- Prefer Homebrew (macOS + Linux) over ad-hoc installers.
- Only use curl installers when a dependency is not available via Homebrew.
- `oh-my-zsh` is installed via the upstream installer (not `git clone`).
- `tmux` TPM/plugins are not installed by bootstrap scripts (manual on first tmux run).
- On Debian/Ubuntu, Docker Engine is installed via apt (`docker.io` + `docker-compose-v2`).
- On Linux, Nerd Fonts are installed via script (Homebrew font casks are macOS-only).

## Linux sandbox (e.g. Lima)

- The move script (`~/.dotfiles/.bootstrap.move.sh`) requires `rsync`.
- The Debian bootstrap script (`~/.bootstrap.debian.sh`) expects:
  - Debian/Ubuntu (`/etc/debian_version` exists)
  - `sudo` available (and ideally passwordless for the provisioned user)
  - network access (installs packages, Homebrew, and fonts)

If you’re provisioning a minimal VM/container, install prerequisites first:

```sh
sudo apt-get update -y
sudo apt-get install -y sudo rsync git
```

Note: `.bootstrap.debian.sh` installs only minimal apt prerequisites; language/tooling deps are handled by `~/.bootstrap.brewfile` via Homebrew.
