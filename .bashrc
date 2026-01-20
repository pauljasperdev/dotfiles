# bash interactive shell config

# Ensure the login profile is applied for non-login shells.
if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

# Fallback Homebrew PATH (keep this simple + path-based).
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
  case ":$PATH:" in
    *":/home/linuxbrew/.linuxbrew/bin:"*) ;;
    *) PATH="/home/linuxbrew/.linuxbrew/bin:$PATH" ;;
  esac
fi
if [ -d "/home/linuxbrew/.linuxbrew/sbin" ]; then
  case ":$PATH:" in
    *":/home/linuxbrew/.linuxbrew/sbin:"*) ;;
    *) PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH" ;;
  esac
fi
if [ -d "/opt/homebrew/bin" ]; then
  case ":$PATH:" in
    *":/opt/homebrew/bin:"*) ;;
    *) PATH="/opt/homebrew/bin:$PATH" ;;
  esac
fi

export PATH
