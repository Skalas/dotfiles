# dotfiles

Personal dotfiles (shell, tmux, Emacs, etc.), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

- Stow
- Emacs 30+ (for claude-code.el and native vterm)
- Node.js (for copilot.el)
- For full install script: see [install.sh](install.sh) (Linux: apt; macOS: Homebrew)

## Setup

1. Install dependencies and tangle all Org files:

   ```bash
   ./install.sh
   ```

   Or tangle separately:

   ```bash
   ./tangle.sh
   ```

2. Link dotfiles into your home directory:

   ```bash
   stow -t ~ .
   ```

   This creates symlinks for config files (e.g. `.tmux.conf`) from this repo into `$HOME`. Files and directories listed in `.stow-local-ignore` are not stowed.

   **Note:** `.zshrc` is excluded from stow — copy or symlink it manually:

   ```bash
   ln -sf ~/github/skalas/dotfiles/.zshrc ~/.zshrc
   ```

## Literate config (Org → tangle → stow)

Several configs are maintained as literate Org files. **Recommended order:** tangle the Org files (from Emacs or `org-babel-tangle`), then run `stow -t ~ .`.

| File | Tangles to | Notes |
|------|------------|--------|
| [Emacs.org](Emacs.org) | `.emacs.d/init.el`, `.emacs.d/early-init.el` | Minimal loader; auto-tangles on save. |
| [emacs/core.org](emacs/core.org) | `.emacs.d/lisp/core.el` | UI, themes, fonts, vertico, consult, projectile, keybindings. |
| [emacs/programming.org](emacs/programming.org) | `.emacs.d/lisp/programming.el`, `.emacs.d/packages/essh.el` | Magit, parens, yasnippet, python, R/ESS, docker, SQL, vterm. |
| [emacs/org-config.org](emacs/org-config.org) | `.emacs.d/lisp/org-config.el` | Babel, agenda, org-modern, org-roam, org-download. |
| [emacs/files.org](emacs/files.org) | `.emacs.d/lisp/files.el` | CSV/JSON/YAML modes, dired, treemacs. |
| [emacs/macos.org](emacs/macos.org) | `.emacs.d/lisp/macos.el` | macOS keybindings, PATH, pdf-tools. |
| [emacs/extras.org](emacs/extras.org) | `.emacs.d/lisp/extras.el` | Writing/LaTeX/markdown, dashboard, AI/copilot/gptel/claude-code. |
| [git.org](git.org) | `.gitconfig` | `.gitconfig` is in `.gitignore` (personal data); tangle locally and stow if desired. |
| [ssh.org](ssh.org) | `.ssh/config` | Tangle then stow. |
| [zsh.org](zsh.org) | `src/skls/aliases`, `src/skls/python/*.zsh`, `src/skls/wsl.zsh` | **Not** `.zshrc`; the canonical source for `.zshrc` is the [.zshrc](.zshrc) file in this repo. |
| [yasnippets.org](yasnippets.org) | `.emacs.d/templates/snippets/...` | Emacs yasnippet templates. |

**Environment variables for AI packages:** export `OPENAI_API_KEY` for gptel/c3po (via direnv + `.env`). Claude Code uses Vertex AI — its env vars are set in `emacs/extras.org`.

## Emacs

Emacs configuration is split into modular literate Org files under `emacs/`. [Emacs.org](Emacs.org) is a minimal bootstrap loader that loads each module from `.emacs.d/lisp/`. Saving any Emacs `.org` file auto-tangles it. To tangle all files at once, run `./tangle.sh`.

## Optional: vitae/

The `vitae/` directory (CV/curriculum, LaTeX) is optional and has its own git history. It is not stowed. Add `vitae/` to `.gitignore` if you do not want it listed in this repo.
