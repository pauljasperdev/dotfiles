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
# macOS (installs Homebrew, then `brew bundle`)
~/.bootstrap.macos.sh

# Debian/Ubuntu (installs packages via apt)
~/.bootstrap.debian.sh
```

Notes:
- macOS installs `uv` via Homebrew.
- Debian/Ubuntu installs `uv` via `curl -LsSf https://astral.sh/uv/install.sh | sh` (installs into `~/.local/bin`).

## Linux sandbox (e.g. Lima)

- The move script (`~/.dotfiles/.bootstrap.move.sh`) requires `rsync`.
- The Debian bootstrap script (`~/.bootstrap.debian.sh`) expects:
  - Debian/Ubuntu (`/etc/debian_version` exists)
  - `sudo` available (and ideally passwordless for the provisioned user)
  - network access (installs packages and runs curl installers)

If you’re provisioning a minimal VM/container, install prerequisites first:

```sh
sudo apt-get update -y
sudo apt-get install -y sudo rsync git
```

Note: `.bootstrap.debian.sh` installs `nodejs` + `npm` via apt; these are required for `pnpm` fallback and `prettierd` installs.
