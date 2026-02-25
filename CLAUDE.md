# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles for macOS/Linux managed with [GNU Stow](https://www.gnu.org/software/stow/). Configs cover zsh (oh-my-zsh + powerlevel10k), tmux, Emacs, and git.

## Key Commands

```bash
# Install dependencies (stow, cmake, fonts) and tangle all Org files
./install.sh

# Or tangle Org files separately (generates .emacs.d/, .gitconfig, etc.)
./tangle.sh

# Symlink dotfiles into $HOME
stow -t ~ .

# Re-stow after adding/removing files
stow -R -t ~ .
```

## Architecture

### Literate Config (Org → Tangle → Stow)

Several configs are authored as Emacs Org files and tangled (via `org-babel-tangle`) into their final locations before stowing:

| Org file | Tangles to | Notes |
|----------|------------|-------|
| `Emacs.org` | `.emacs.d/init.el`, `.emacs.d/early-init.el` | Minimal loader; auto-tangles on save |
| `emacs/core.org` | `.emacs.d/lisp/core.el` | UI, themes, fonts, vertico, consult, projectile, keybindings |
| `emacs/programming.org` | `.emacs.d/lisp/programming.el`, `.emacs.d/packages/essh.el` | Magit, parens, yasnippet, python, R/ESS, docker, SQL, vterm |
| `emacs/org-config.org` | `.emacs.d/lisp/org-config.el` | Babel, agenda, org-modern, org-roam, org-download |
| `emacs/files.org` | `.emacs.d/lisp/files.el` | CSV/JSON/YAML modes, dired, treemacs |
| `emacs/macos.org` | `.emacs.d/lisp/macos.el` | macOS keybindings, PATH, pdf-tools |
| `emacs/extras.org` | `.emacs.d/lisp/extras.el` | Writing/LaTeX/markdown, dashboard, auto-update, AI/copilot/gptel |
| `git.org` | `.gitconfig` | `.gitconfig` is gitignored (contains personal data) |
| `ssh.org` | `.ssh/config` | |
| `zsh.org` | `src/skls/aliases`, `src/skls/python/*.zsh`, `src/skls/wsl.zsh` | Does NOT produce `.zshrc` |
| `yasnippets.org` | `.emacs.d/templates/snippets/...` | |

**Important:** `.zshrc` is maintained directly as a plain file, not tangled from `zsh.org`. The Org file's zsh blocks are `:tangle no` and kept as reference only.

### Stow Ignore

`.stow-local-ignore` excludes Org files, `README.md`, `install.sh`, `.gitignore`, and other non-config files from being symlinked.

### Shell Setup

`.zshrc` uses oh-my-zsh with powerlevel10k theme (via Homebrew). It sources:
- `~/src/skls/aliases` — custom shell aliases and functions (tangled from `zsh.org`)
- `~/src/skls/python/conda_initialize.zsh` — conda setup
- direnv for environment variables
- Google Cloud SDK from `src/google-cloud-sdk/`

### Secrets

API keys (e.g. `OPENAI_API_KEY` for Emacs gptel) should be managed via direnv + `.env`, never committed. The `.env` file in the repo root is gitignored.
