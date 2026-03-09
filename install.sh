#!/usr/bin/env bash
# Install dependencies, tangle Org files, stow configs, and set up .zshrc.
# Linux: Debian/Ubuntu (apt). macOS: requires Homebrew (https://brew.sh).

set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Homebrew (macOS and Linux)
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Make brew available in current session
  if [[ "$(uname -s)" == Linux ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# Core packages via Homebrew
for pkg in stow cmake coreutils git direnv fortune tmux emacs uv node rbenv; do
  brew list "$pkg" &>/dev/null || brew install "$pkg"
done

# macOS extras
if [[ "$(uname -s)" == Darwin ]]; then
  for cask in font-fira-code-nerd-font font-cantarell; do
    brew list --cask "$cask" &>/dev/null || brew install --cask "$cask" 2>/dev/null || true
  done
  # iTerm2 (skip if already installed via app or brew)
  if [[ ! -d /Applications/iTerm.app ]] && ! brew list --cask iterm2 &>/dev/null; then
    brew install --cask iterm2 2>/dev/null || true
  fi
  # Docker Desktop (skip if already installed via app or brew)
  if ! command -v docker &>/dev/null; then
    brew install --cask docker 2>/dev/null || true
  fi
fi

# Linux extras
if [[ "$(uname -s)" == Linux ]]; then
  sudo apt update && sudo apt install -y fonts-firacode fonts-cantarell xclip
  # Docker
  if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
  fi
fi

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Tmux Plugin Manager (TPM)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  echo "Installing TPM..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Tangle Org files
echo "Tangling Org files..."
"$DOTFILES_DIR/tangle.sh"

# Stow dotfiles into $HOME (--no-folding prevents stow from symlinking
# entire directories, so runtime files like .emacs.d/straight/ don't end
# up inside the dotfiles repo)
echo "Stowing dotfiles..."
stow -R --no-folding -t ~ -d "$(dirname "$DOTFILES_DIR")" "$(basename "$DOTFILES_DIR")"

# Copy .zshrc (not symlinked — each machine may diverge via ~/.zshrc.local)
# Back up existing .zshrc with rotating suffix (.bak, .bak1, .bak2, ...)
if [[ -f ~/.zshrc ]]; then
  bak="$HOME/.zshrc.bak"
  if [[ ! -f "$bak" ]]; then
    cp ~/.zshrc "$bak"
  else
    n=1
    while [[ -f "${bak}${n}" ]]; do ((n++)); done
    cp ~/.zshrc "${bak}${n}"
  fi
fi
echo "Installing .zshrc..."
cp "$DOTFILES_DIR/.zshrc" ~/.zshrc

# Create starter ~/.zshrc.local if it doesn't exist
if [[ ! -f ~/.zshrc.local ]]; then
  echo "Creating ~/.zshrc.local..."
  cat > ~/.zshrc.local <<'EOF'
# Machine-specific shell config (not tracked in dotfiles).
# Add gcloud, iTerm2, or other local setup here.

# Examples:
# command -v fortune &>/dev/null && fortune -s
# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
EOF
fi

echo "Done."
