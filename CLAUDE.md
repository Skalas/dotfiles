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

Several configs are authored as Emacs Org files and tangled (via `org-babel-tangle`) into their final locations before stowing. All Org files use `#+auto_tangle: t` for automatic tangling on save via `org-auto-tangle`.

| Org file | Tangles to | Notes |
|----------|------------|-------|
| `Emacs.org` | `.emacs.d/init.el`, `.emacs.d/early-init.el` | Bootstrap loader (straight.el + use-package) and module loading |
| `emacs/core.org` | `.emacs.d/lisp/core.el` | UI, themes, fonts, completion (vertico/orderless/consult/marginalia), projectile, keybindings |
| `emacs/programming.org` | `.emacs.d/lisp/programming.el` | Magit, corfu, yasnippet, python (eglot + apheleia), R/ESS, docker, SQL/polymode, vterm |
| `emacs/org-config.org` | `.emacs.d/lisp/org-config.el` | Babel, agenda, org-modern, org-appear, org-roam, org-download |
| `emacs/files.org` | `.emacs.d/lisp/files.el` | CSV/JSON/YAML modes, dired, treemacs |
| `emacs/macos.org` | `.emacs.d/lisp/macos.el` | macOS fonts, PATH/exec-path, Spanish keyboard bindings, pdf-tools |
| `emacs/extras.org` | `.emacs.d/lisp/extras.el` | LaTeX, markdown, dashboard, AI (copilot, gptel, claude-code) |
| `git.org` | `.gitconfig` | `.gitconfig` is gitignored (contains personal data) |
| `ssh.org` | `.ssh/config` | |
| `zsh.org` | `src/skls/aliases`, `src/skls/python/*.zsh`, `src/skls/wsl.zsh` | Does NOT produce `.zshrc` |
| `yasnippets.org` | `.emacs.d/templates/snippets/...` | |

**Important:** `.zshrc` is maintained directly as a plain file, not tangled from `zsh.org`. The Org file's zsh blocks are `:tangle no` and kept as reference only.

### Emacs Package Stack

All packages managed via [straight.el](https://github.com/radian-software/straight.el) (`straight-use-package-by-default t`). Package.el is disabled in `early-init.el`.

**Completion:** vertico + orderless + marginalia + consult + corfu + cape (the "minad stack")

**Programming:** eglot (LSP, built-in), apheleia (formatting), magit, smartparens, rainbow-delimiters, yasnippet

**Org:** org-modern, org-appear, org-roam + org-roam-ui, org-download, org-auto-tangle

**AI:** copilot.el (`copilot-emacs/copilot.el`), gptel, claude-code.el (via Vertex AI)

**UI:** doom-themes (zenburn), doom-modeline, nerd-icons, perspective.el, treemacs, dashboard

### Key Bindings (custom)

| Binding | Action | Source |
|---------|--------|--------|
| `C-c a` | org-agenda | core (general) |
| `C-c b` | consult-bookmark | core (general) |
| `C-c o` | org-capture | core (general) |
| `C-c c` | claude-code command map | extras |
| `C-c p` | projectile command map | core |
| `C-c x` | perspective prefix | core |
| `C-c n l/f/i` | org-roam (toggle/find/insert) | org-config |
| `C-s` | consult-line | core |
| `C-d` | mc/mark-next-like-this | core |
| `F12` | vterm | programming |
| `M-c` | send line/region to vterm | programming |
| `M-0` | treemacs-select-window | files |

### Stow Ignore

`.stow-local-ignore` excludes Org files, `README.md`, `install.sh`, `tangle.sh`, `.gitignore`, the `emacs/` directory, `.claude/`, `.cursor/`, and other non-config files from being symlinked. Note: `.zshrc` is also excluded — it must be manually symlinked or copied.

### Shell Setup

`.zshrc` uses oh-my-zsh with powerlevel10k theme (via Homebrew). It sources:
- `~/src/skls/aliases` — custom shell aliases and functions (tangled from `zsh.org`)
- `~/src/skls/python/conda_initialize.zsh` — conda setup
- direnv for environment variables
- Google Cloud SDK from `src/google-cloud-sdk/`

### Secrets & AI Configuration

API keys (e.g. `OPENAI_API_KEY` for Emacs gptel) should be managed via direnv + `.env`, never committed. The `.env` file in the repo root is gitignored.

Claude Code runs via Vertex AI. The environment variables (`CLAUDE_CODE_USE_VERTEX`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID`) are set in `emacs/extras.org` for the Emacs integration and in `~/.envrc` for shell usage.
