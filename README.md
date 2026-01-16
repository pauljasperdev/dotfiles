# dotfiles

My config files and bootstrap scripts.

## Getting Started

<ol>

<li> Clone

```sh
git clone https://github.com/pauljasperdev/dotfiles ~/.dotfiles
```

</li>

<li> Move config files

This overwrites top-level dotfiles like `~/.zshrc` and `~/.tmux.conf` and merges folders in `~/.config/`.

```sh
~/.dotfiles/.bootstrap.move.sh
```

</li>

<li> Install dependencies

```sh
# macOS
~/.bootstrap.macos.sh

# Debian/Ubuntu
~/.bootstrap.debian.sh
```

</li>

</ol>
