# dotfiles

Personal dotfiles (shell, tmux, Emacs, etc.), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

- Stow
- For full install script: see [install.sh](install.sh) (Linux: apt; macOS: Homebrew)

## Setup

1. Install dependencies (optional, for scripted install):

   ```bash
   ./install.sh
   ```

2. Link dotfiles into your home directory:

   ```bash
   stow -t ~ .
   ```

   This creates symlinks for config files (e.g. `.tmux.conf`, `.zshrc`) from this repo into `$HOME`. Files and directories listed in `.stow-local-ignore` are not stowed.

## Literate config (Org → tangle → stow)

Several configs are maintained as literate Org files. **Recommended order:** tangle the Org files (from Emacs or `org-babel-tangle`), then run `stow -t ~ .`.

| File | Tangles to | Notes |
|------|------------|--------|
| [Emacs.org](Emacs.org) | `~/.emacs.d/init.el`, `~/.emacs.d/early-init.el` | Tangles on save when buffer is in this repo. |
| [git.org](git.org) | `./.gitconfig` | `.gitconfig` is in `.gitignore` (personal data); tangle locally and stow if desired. |
| [ssh.org](ssh.org) | `~/.ssh/config` | Tangle then stow. |
| [zsh.org](zsh.org) | `src/skls/aliases`, `src/skls/python/*.zsh`, `src/skls/wsl.zsh` | **Not** `.zshrc`; the canonical source for `.zshrc` is the [.zshrc](.zshrc) file in this repo. |
| [yasnippets.org](yasnippets.org) | `~/.emacs.d/templates/snippets/...` | Emacs yasnippet templates. |

**Environment variables for AI packages (gptel, c3po):** export `OPENAI_API_KEY` in your environment (e.g. in `.envrc` with direnv, or in `.zshrc`). Prefer direnv + `.env` so secrets are not committed.

## Emacs

Emacs configuration is maintained as a literate Org file: [Emacs.org](Emacs.org). It tangles to `~/.emacs.d/init.el` when saved from this repo (if the buffer is in the same directory as `Emacs.org`).

## Optional: vitae/

The `vitae/` directory (CV/curriculum, LaTeX) is optional and has its own git history. It is not stowed. Add `vitae/` to `.gitignore` if you do not want it listed in this repo.
