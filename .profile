# Homebrew (login shells)
# Use absolute paths so this works even if Homebrew
# isn't on PATH yet.
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# uv
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
  esac
  export PATH
fi
