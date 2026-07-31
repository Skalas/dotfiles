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
for pkg in stow cmake coreutils git direnv fortune tmux uv node rbenv pandoc d2; do
  brew list "$pkg" &>/dev/null || brew install "$pkg"
done

# Markdown tooling (pandoc renders markdown-mode previews; grip serves live GFM
# previews for grip-mode; mmdc renders mermaid diagrams)
command -v grip &>/dev/null || uv tool install grip
# --allow-scripts is required: mermaid-cli renders through puppeteer, whose
# postinstall downloads Chromium. Without it mmdc installs but cannot render.
command -v mmdc &>/dev/null || npm install -g --allow-scripts=puppeteer @mermaid-js/mermaid-cli

# Emacs (emacs-plus on macOS for GUI/Spotlight support, apt on Linux)
if [[ "$(uname -s)" == Darwin ]]; then
  # Remove plain emacs if installed (no GUI/Spotlight support)
  brew list emacs &>/dev/null && brew uninstall emacs

  EMACS_BIN=/opt/homebrew/opt/emacs-plus@30/bin/emacs
  # --with-xwidgets is required: grip-mode previews markdown in an embedded
  # WebKit buffer, and without this flag `xwidget-internal' is absent and grip
  # silently falls back to an external browser. Checking the feature rather than
  # just "is it installed" means a machine with an older non-xwidget build gets
  # corrected instead of skipped.
  emacs_has_xwidgets() {
    [[ -x "$EMACS_BIN" ]] && "$EMACS_BIN" --batch \
      --eval '(kill-emacs (if (featurep (quote xwidget-internal)) 0 1))' 2>/dev/null
  }
  if ! emacs_has_xwidgets; then
    brew tap d12frosted/emacs-plus
    if brew list emacs-plus@30 &>/dev/null; then
      echo "Rebuilding emacs-plus@30 with --with-xwidgets..."
      brew reinstall emacs-plus@30 --with-xwidgets
    else
      brew install emacs-plus@30 --with-xwidgets
    fi
  fi

  # Alias (not a copy) into /Applications for Spotlight. An alias always resolves
  # to the current Cellar build, so it never goes stale after a brew upgrade —
  # whereas `cp -r` both drifts and fails outright once an alias is in place
  # (cp cannot overwrite a non-directory with a directory).
  for app in "Emacs" "Emacs Client"; do
    if [[ ! -e "/Applications/$app.app" ]]; then
      osascript -e "tell application \"Finder\" to make alias file \
        to posix file \"/opt/homebrew/opt/emacs-plus@30/$app.app\" \
        at posix file \"/Applications\"" >/dev/null 2>&1 || \
        echo "Could not create /Applications/$app.app alias (create it manually)."
    fi
  done

  # Run the daemon under launchd so it starts at login and, after an upgrade,
  # `brew services restart emacs-plus@30` picks up the new binary. Previously the
  # daemon was started by hand and could run a long-since-replaced build.
  # Safe despite launchd's minimal PATH because macos.el sets exec-path/PATH.
  if ! brew services list 2>/dev/null | grep -qE "^emacs-plus@30\s+started"; then
    brew services start d12frosted/emacs-plus/emacs-plus@30 || \
      echo "Could not start emacs-plus service; run the daemon manually."
  fi
else
  command -v emacs &>/dev/null || sudo apt install -y emacs
fi

# macOS extras
if [[ "$(uname -s)" == Darwin ]]; then
  # Families the Emacs config actually asks for, by cask:
  #   font-fira-code            -> "Fira Code"              (default face)
  #   font-fira-code-nerd-font  -> "FiraCode Nerd Font"      (fallback, glyphs)
  #   font-cantarell            -> "Cantarell"               (org headings)
  #   font-symbols-only-nerd-font -> "Symbols Nerd Font Mono" (nerd-icons; without
  #     it nerd-icons re-downloads the font on every graphical startup)
  #   font-meslo-lg-nerd-font   -> "MesloLGS Nerd Font"       (vterm fallback)
  # Note: powerlevel10k's own "MesloLGS NF" is NOT a Homebrew cask — its font
  # wizard installs it. The vterm face falls back to the cask family above.
  for cask in font-fira-code font-fira-code-nerd-font font-cantarell \
              font-symbols-only-nerd-font font-meslo-lg-nerd-font; do
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

# Link the straight.el lockfile into place so package versions are reproducible.
# It is tracked in the repo (under emacs/, which stow ignores) and symlinked here;
# M-x straight-freeze-versions then writes straight through to the repo.
VERSIONS_DIR="$HOME/.emacs.d/straight/versions"
mkdir -p "$VERSIONS_DIR"
if [[ ! -L "$VERSIONS_DIR/default.el" ]]; then
  [[ -f "$VERSIONS_DIR/default.el" ]] && mv "$VERSIONS_DIR/default.el" "$VERSIONS_DIR/default.el.bak"
  ln -s "$DOTFILES_DIR/emacs/straight-versions.el" "$VERSIONS_DIR/default.el"
  echo "Linked straight lockfile."
fi

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
