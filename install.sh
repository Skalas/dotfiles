#!/usr/bin/env bash
# Install dependencies for dotfiles (stow, cmake, fonts).
# Linux: Debian/Ubuntu (apt). macOS: requires Homebrew (https://brew.sh).

set -e
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

echo "Tangling Org files..."
"$(dirname "$0")/tangle.sh"
