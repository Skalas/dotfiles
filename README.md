# dotfiles

Personal dotfiles (shell, tmux, Emacs, etc.), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

- Emacs 29+ (eglot, use-short-answers, corfu compatibility)
- Node.js (for copilot.el)
- A [Nerd Font](https://www.nerdfonts.com/) (Fira Code Nerd Font recommended)
- macOS: Homebrew (auto-installed by `install.sh` if missing)
- Linux: apt (Debian/Ubuntu)

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

Several configs are maintained as literate Org files. All use `#+auto_tangle: t` so saving in Emacs auto-tangles them. To tangle all files at once, run `./tangle.sh`.

| File | Tangles to | Description |
|------|------------|-------------|
| [Emacs.org](Emacs.org) | `.emacs.d/init.el`, `.emacs.d/early-init.el` | Bootstrap (straight.el + use-package) and module loading |
| [emacs/core.org](emacs/core.org) | `.emacs.d/lisp/core.el` | UI, themes, fonts, completion stack, projectile, keybindings |
| [emacs/programming.org](emacs/programming.org) | `.emacs.d/lisp/programming.el` | Magit, corfu, yasnippet, python, R/ESS, docker, SQL, vterm |
| [emacs/org-config.org](emacs/org-config.org) | `.emacs.d/lisp/org-config.el` | Babel, agenda, org-modern, org-appear, org-roam, org-download |
| [emacs/files.org](emacs/files.org) | `.emacs.d/lisp/files.el` | CSV/JSON/YAML modes, dired, treemacs |
| [emacs/macos.org](emacs/macos.org) | `.emacs.d/lisp/macos.el` | macOS fonts, PATH, Spanish keyboard, pdf-tools |
| [emacs/extras.org](emacs/extras.org) | `.emacs.d/lisp/extras.el` | LaTeX, markdown, dashboard, AI integrations |
| [git.org](git.org) | `.gitconfig` | Gitignored (personal data); tangle locally |
| [ssh.org](ssh.org) | `.ssh/config` | SSH hosts and key config |
| [zsh.org](zsh.org) | `src/skls/aliases`, `src/skls/python/*.zsh`, `src/skls/wsl.zsh` | Shell helpers; `.zshrc` is a separate plain file |
| [yasnippets.org](yasnippets.org) | `.emacs.d/templates/snippets/...` | Emacs yasnippet templates |

**Environment variables for AI packages:** export `OPENAI_API_KEY` for gptel (via direnv + `.env`). Claude Code uses Vertex AI — its env vars are set in `emacs/extras.org`.

## Emacs

### Module overview

The Emacs config is split into modular literate Org files under `emacs/`. [Emacs.org](Emacs.org) bootstraps straight.el and loads each module from `.emacs.d/lisp/`.

#### Completion stack (minad)

[vertico](https://github.com/minad/vertico) (minibuffer) + [orderless](https://github.com/obolber/orderless) (matching) + [marginalia](https://github.com/minad/marginalia) (annotations) + [consult](https://github.com/minad/consult) (commands) + [corfu](https://github.com/minad/corfu) (in-buffer) + [cape](https://github.com/minad/cape) (completion-at-point extensions)

#### Programming

- **LSP:** eglot (built-in) — hooked to python-mode
- **Formatting:** apheleia (async, supports ruff/black/isort/prettier)
- **Git:** magit
- **Parens:** smartparens + rainbow-delimiters
- **Snippets:** yasnippet + yasnippet-snippets
- **Python:** eglot, apheleia, poetry, sphinx-doc
- **R:** ESS, poly-R
- **SQL:** polymode (jinja2 + SQL), flymake-sqlfluff
- **Terminal:** vterm (`F12` to open, `M-c` to send line/region)

#### Org-mode

- **Visual:** org-modern (styled headings/blocks), org-appear (show markup on cursor)
- **Notes:** org-roam + org-roam-ui (zettelkasten)
- **Capture:** org-capture templates for tasks, journal, meetings
- **Agenda:** custom dashboard with per-tag views
- **Presentations:** org-tree-slide, ox-reveal (on demand)
- **Images:** org-download (clipboard/drag-and-drop)
- **Export:** ox-gfm (GitHub-flavored markdown)

#### AI

- **Copilot:** [copilot.el](https://github.com/copilot-emacs/copilot.el) — inline completions in prog-mode
- **gptel:** LLM chat interface (OpenAI, configurable for Claude/Gemini/Ollama)
- **Claude Code:** [claude-code.el](https://github.com/stevemolitor/claude-code.el) via Vertex AI (`C-c c`)

#### UI & navigation

- **Theme:** doom-zenburn (doom-themes + doom-modeline)
- **Icons:** nerd-icons (requires a Nerd Font)
- **File tree:** treemacs (with projectile, magit, perspective integrations)
- **Workspaces:** perspective.el (`C-c x`)
- **Dashboard:** startup screen with recent files, projects, agenda

### Key bindings

| Binding | Action |
|---------|--------|
| `C-c a` | org-agenda |
| `C-c b` | consult-bookmark |
| `C-c o` | org-capture |
| `C-c c` | claude-code commands |
| `C-c p` | projectile commands |
| `C-c x` | perspective commands |
| `C-c n l/f/i` | org-roam toggle/find/insert |
| `C-s` | consult-line (search in buffer) |
| `C-d` / `C-M-d` | mark next/previous like this (multiple cursors) |
| `F12` | open vterm |
| `M-c` | send line/region to vterm |
| `M-0` | treemacs window |
| `C-+` / `C--` | text scale increase/decrease |

### Package management

All packages via [straight.el](https://github.com/radian-software/straight.el). Package.el is disabled. Update all with `M-x straight-pull-all`.
