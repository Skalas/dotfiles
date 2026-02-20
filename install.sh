#!/usr/bin/env bash
# Install dependencies for dotfiles (stow, cmake, fonts).
# Linux: Debian/Ubuntu (apt). macOS: requires Homebrew (https://brew.sh).

set -e
case "$(uname -s)" in
  Darwin)
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required on macOS. Install from https://brew.sh"
      exit 1
    fi
    brew install stow cmake
    brew install --cask font-fira-code font-cantarell 2>/dev/null || true
    ;;
  Linux)
    sudo apt update && sudo apt install -y cmake libtool-bin stow fonts-firacode fonts-cantarell xclip
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
