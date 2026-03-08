#!/usr/bin/env bash
# Install dependencies, tangle Org files, stow configs, and symlink .zshrc.
# Linux: Debian/Ubuntu (apt). macOS: requires Homebrew (https://brew.sh).

set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install dependencies
case "$(uname -s)" in
  Darwin)
    if ! command -v brew &>/dev/null; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    for pkg in stow cmake coreutils git; do
      brew list "$pkg" &>/dev/null || brew install "$pkg"
    done
    for cask in font-fira-code-nerd-font font-cantarell; do
      brew list --cask "$cask" &>/dev/null || brew install --cask "$cask" 2>/dev/null || true
    done
    ;;
  Linux)
    sudo apt update && sudo apt install -y cmake libtool-bin stow fonts-firacode fonts-cantarell xclip
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

# Tangle Org files
echo "Tangling Org files..."
"$DOTFILES_DIR/tangle.sh"

# Stow dotfiles into $HOME
echo "Stowing dotfiles..."
stow -R -t ~ -d "$(dirname "$DOTFILES_DIR")" "$(basename "$DOTFILES_DIR")"

# Symlink .zshrc (excluded from stow via .stow-local-ignore)
echo "Symlinking .zshrc..."
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc

echo "Done."
