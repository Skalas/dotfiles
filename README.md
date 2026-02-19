# dotfiles

Personal dotfiles (shell, tmux, Emacs, etc.), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

- Stow
- For full install script: cmake, libtool-bin, fonts-firacode, fonts-cantarell, xclip (see `install.sh`)

## Setup

1. Install dependencies (optional, for scripted install):

   ```bash
   ./install.sh
   ```2. Link dotfiles into your home directory:

   ```bash
   stow -t ~ .
   ```

   This creates symlinks for config files (e.g. `.tmux.conf`, `.zshrc`) from this repo into `$HOME`. Files and directories listed in `.stow-local-ignore` are not stowed.

## Emacs

Emacs configuration is maintained as a literate Org file: [Emacs.org](Emacs.org). It tangles to `~/.emacs.d/init.el` when saved from this repo (if the buffer is in the same directory as `Emacs.org`).

**Environment variables for AI packages (gptel, c3po):** export `OPENAI_API_KEY` in your environment (e.g. in `.envrc` with direnv, or in `.zshrc`).
