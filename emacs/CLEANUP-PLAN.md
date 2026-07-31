# Emacs config cleanup & modernization plan

Working document. Every item has a **verify** step and a **do** step, so we can
tackle them one at a time and confirm each landed. Checked boxes = done and verified.

Baseline: GNU Emacs 30.2 (emacs-plus@30, `--with-xwidgets`), straight.el +
use-package, literate Org config across 7 files.

**Status (2026-07-30):** Phases 0–4 done, plus 5.1/5.2, 6.1–6.3 and 7.1–7.4.
Repos on disk 130 → **89** (41 purged, 1.3G → 1.0G); package versions pinned in
`emacs/straight-versions.el` (89 entries); **init 4.2s → 0.9s**; module loading is
now fault-isolated. The full-init batch smoke test passes — it had never passed
before, because of item 1.1.

Answered decisions driving this pass: no Neo4j/Cypher, no reveal.js
presentations, no in-Emacs debugging, and direnv + `uv` is the complete Python
setup (so no Emacs-side venv manager).

This file lives under `emacs/`, which `.stow-local-ignore` excludes — it will not
be symlinked into `$HOME`.

---

## The verification harness

Use the real binary, not the `emacs` shell alias (that alias points at
`emacsclient`, so it talks to the daemon and won't test a config change):

```bash
E=/opt/homebrew/opt/emacs-plus@30/bin/emacs
```

**Tangle:**
```bash
$E --batch -l org --eval '(org-babel-tangle-file "emacs/core.org")'
./tangle.sh   # all files
```

**Full-init smoke test** — the single most valuable check. Currently *blocked* by
item 1.1; it works as soon as that is fixed:
```bash
$E --batch -l ~/.emacs.d/init.el --eval '(princ "\nINIT-OK\n")'
```

**Single module, isolated:**
```bash
$E --batch --eval '(progn
  (load (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory) nil t)
  (straight-use-package (quote use-package)) (setq straight-use-package-by-default t)
  (add-to-list (quote load-path) (expand-file-name "lisp" user-emacs-directory))
  (load "core") (princ "\nCORE-OK\n"))'
```

**After each phase:** restart the daemon, since a running daemon holds the old
config in memory:
```bash
emacsclient --eval '(save-some-buffers t)' && pkill -f -- '--bg-daemon'
/opt/homebrew/bin/emacs --bg-daemon
```

---

## Phase 0 — Safety net first

- [x] **0.1 Freeze package versions.** DONE, but not by the route planned above.
  Two things the original plan got wrong:
  - A `!` negation in `.gitignore` cannot re-include anything under `.emacs.d`,
    because git refuses to re-include a path whose **parent directory** is
    excluded.
  - More fundamentally, `~/.emacs.d/straight/` is not in the repo at all —
    `install.sh` uses `stow --no-folding` specifically to keep runtime dirs out.
  - **Actual solution:** the lockfile is tracked at `emacs/straight-versions.el`
    (inside `emacs/`, which stow ignores) and symlinked to
    `~/.emacs.d/straight/versions/default.el`. `straight-freeze-versions` writes
    *through* the symlink into the repo — verified the symlink survives a freeze.
    `install.sh` recreates the link on a fresh machine.
  - Also learned: `straight-freeze-versions` only records packages the **running
    session actually loaded**. Run from `--batch` with just straight bootstrapped
    it froze 9 recipe repos; run after a full `init.el` load it froze 89. Always
    freeze from a full init.

- [ ] **0.2 Commit each phase.** NOT DONE — no commits made. All changes are in
  the working tree for review. Suggest one commit per phase before continuing.

---

## Phase 1 — Confirmed bugs

All four verified locally.

- [x] **1.1 `treemacs-start-on-boot` blocks startup** — `files.org:71`.
  On a machine with no persisted treemacs workspace it calls
  `treemacs--read-first-project-path`, which prompts `"Project root: "` during
  init. Everything loaded after it — `macos.el` and `extras.el` — never runs.
  - **Evidence:** batch init dies with `end-of-file ("Error reading from stdin")`
    at `treemacs--read-first-project-path()` → `treemacs-start-on-boot()` →
    `files.el`. Your machine hides this because the workspace already exists.
  - **Do:** either drop the call (treemacs opens fine on demand via `M-0` /
    `C-x t t`), or guard it on the persist file existing.
  - **Verify:** the full-init smoke test above prints `INIT-OK`.

- [x] **1.2 Org tag `?i` bound twice** — `org-config.org:74` (`@ITAM`) and
  `:78` (`idea`). The second is unreachable from the tag-selection UI.
  - **Do:** rebind one, e.g. `idea` → `?d`.
  - **Verify:** `C-c C-q` in an Org buffer offers both distinctly.

- [x] **1.3 `:ensure t` under straight** — `org-config.org:161` (`ob-cypher`),
  `:182` (`visual-fill-column`). `:ensure` is a package.el keyword and does
  nothing here; straight handles installation via
  `straight-use-package-by-default`.
  - **Do:** delete both.

- [x] **1.4 `:diminish` with no `diminish` package** — `core.org:178`
  (`which-key`), `:186` (`projectile`), `:238` (`multiple-cursors`).
  - **Evidence:** `(locate-library "diminish")` → `nil`; the package is not
    declared anywhere and not among the 129 cloned repos. The keywords have no
    effect — those lighters are not actually being hidden.
  - **Do:** either add `diminish` as a real dependency, or delete the three
    keywords. Deleting is simpler; `doom-modeline` already keeps the modeline tidy.

---

## Phase 2 — Stop shipping what Emacs 30 includes

- [x] **2.1 Drop third-party `which-key`** — `core.org:176`. Built into Emacs 30;
  verified locally that `which-key` resolves outside `straight/`.
  - **Do:** `(use-package which-key :straight nil :init (which-key-mode) :custom (which-key-idle-delay 0.7))`.
    Built-in ≠ enabled, so keep the `which-key-mode` call.
  - **Verify:** `which-key` disappears from `straight-remove-unused-repos` candidates
    and `C-c` still shows the popup.

- [x] **2.2 `visual-fill-column` → `olivetti`** — `org-config.org:180-186`.
  The GitHub repo is **archived** (last push 2021-11-18); development moved to
  Codeberg and it still ships on NonGNU ELPA, so it isn't abandoned — but for
  your actual usage (`visual-fill-column-center-text t`) `olivetti` is the
  maintained, purpose-built option. Emacs 30's built-in `visual-wrap-prefix-mode`
  covers the *wrapping* half if you want that separately.
  - **Note:** this also fixes a Phase 3 anti-pattern — it's currently installed
    from inside a function body.

- [ ] **2.3 Optional: adopt built-in `editorconfig-mode`.** Verified available in
  your build. Not currently used at all; add only if you want `.editorconfig`
  honored.

---

## Phase 3 — Dead code and anti-patterns

- [x] **3.1 Delete dead defuns.** `skls/org-treeslide` (`org-config.org:8`) and
  `skls/org-reveal` (`:140`) are defined and **never called** — each name appears
  exactly once across all Org files. So `org-tree-slide`, `ox-reveal`, and
  `htmlize` are declared but never actually load.
  - **Decision needed:** do you still want reveal.js presentations? If yes, lift
    them to top-level `use-package` with `:commands`. If no, delete all three.

- [x] **3.2 Lift `use-package` out of function bodies.** Five sites call
  `use-package` at runtime, inside a function invoked from a hook:
  `skls/org-modern`, `skls/org-mode-visual-fill`, `skls/org-treeslide`,
  `skls/org-reveal`, `skls/create-poly-jinja` (`jinja2-mode`).
  `use-package` is a macro meant for top level; from a hook it re-runs its
  configuration on every single invocation and defeats deferred loading.
  - **Do:** move each to a top-level `use-package` with `:hook`/`:mode`/`:commands`.

- [x] **3.3 Purge orphaned repos.** 129 repos cloned vs 68 declared. Leftovers
  from removed config include `copilot.el` (config removed in `9e88b74`),
  `company-mode`, `company-box`, `counsel-projectile`, `swiper`, `ivy`,
  `all-the-icons*` (superseded by `nerd-icons`), `python-mode`, `pyvenv`,
  `emacs-python-black`, `editorconfig-emacs`, `el-get`, `auto-package-update`,
  `persp-mode.el`, `shell-pop-el`, `mode-line-bell`, `c3po.el`, `ace-window`,
  `avy`, `ripgrep.el`.
  - **Do:** `M-x straight-remove-unused-repos` — it computes the true orphan set
    (do **not** hand-delete; many of the 129 are legitimate transitive deps like
    `dash`, `compat`, `transient`, and straight's own recipe mirrors).
  - **Verify:** run *after* Phase 0.1 so the lockfile records the intended set,
    then re-run the init smoke test.

---

## Phase 4 — Stale upstreams (evidence table)

Last push dates from the GitHub API, July 30 2026:

| Package | Last push | Status | Recommendation |
|---|---|---|---|
| `visual-fill-column` | 2021-11-18 | **archived** on GitHub (moved to Codeberg) | → `olivetti` (2.2) |
| `ob-cypher` | 2021-02-19 | 5 yrs stale, 24 ★ | **Decision:** still using Neo4j/Cypher? |
| `sphinx-doc` | 2022-11-15 | 3.5 yrs stale | Drop unless you write Sphinx docstrings |
| `ox-reveal` | 2023-10-22 | stale + dead code (3.1) | Drop with 3.1 |
| `jinja2-mode` | 2023-12-27 | stale but functional | Keep — no better option for the SQL+Jinja polymode |
| `poetry.el` | 2024-06-23 | maintained-ish | → `pet.el`, see 4.1 |
| `realgud` | 2026-07-25 | **actively maintained** | See 4.2 |
| everything else | 2025-06 → 2026-07 | healthy | Keep |

- [x] **4.1 `poetry.el` → `pet.el`.** `programming.org:70`. This one contradicts
  your own standard: `CLAUDE.md` says "Always use `uv` instead of `pip`… never
  default to pip", but the config only automates Poetry. `pet.el` detects the
  venv for whatever tool the project uses — `uv.lock`, `poetry.lock`, bare
  `.venv` — and wires `eglot` to the right interpreter with no per-project config.
  - **Note:** you already have `envrc` (`core.org:104`), which covers a lot of
    this if your projects use direnv. Check whether `pet` is additive for you or
    redundant before adding it.

- [x] **4.2 `realgud`: declared, zero config, likely unused.**
  `programming.org:45` is a bare `(use-package realgud)`. I was wrong to assume
  it was abandoned — it's actively maintained. The question is whether *you* use
  it.
  - **Decision needed:** delete it, or replace with `dape` (DAP client, in GNU
    ELPA, no external deps, v0.26.0 Feb 2026) if you want real debugging.

---

## Phase 5 — Optional modernization

- [x] **5.1 Python hooks are treesit-blind.** Four sites hook `python-mode`
  specifically (`programming.org:68` apheleia, `:76` eglot, `:79` sphinx-doc,
  `:81` tab-width). Under `python-ts-mode` none of them fire.
  - **Do:** hook `python-base-mode` instead — it covers both — even if you never
    switch to treesit. Cheap insurance.
  - **Note:** `treesit-available-p` → `t` on your build, but
    `~/.emacs.d/tree-sitter/` is empty, so no grammars are installed and you are
    currently on the classic modes throughout.

- [x] **5.2 `org-roam-ui-open-on-start t`** (`org-config.org:269`) launches a
  browser whenever org-roam-ui loads. Consider `nil` and opening it deliberately.

- [ ] **5.3 macOS Spanish-character bindings shadow standard keys**
  (`macos.org:28-46`). `M-a`/`M-e` are sentence motion, `M-i` is
  `tab-to-tab-stop`, `M-o` and `M-u` have mode-specific meanings, and `M-n`
  collides with the `M-n M-i` chunk binding in `poly-R`
  (`programming.org:134`). Deliberate trade-off, not a bug — flagging so the
  choice is explicit. A dedicated prefix (e.g. `C-c 8 a`) would avoid the
  collisions.

- [ ] **5.4 GUI-verify `(set-fringe-mode -1)`** (`core.org:25`). `-1` is not a
  documented argument (`0` = no fringes, `nil` = default). My batch probe was
  inconclusive — both `0` and `-1` report `nil` widths in `--batch`. Check in a
  GUI frame whether fringes are actually hidden; if not, change to `0`.

---

## Second pass — startup performance & resilience (2026-07-30)

- [x] **6.1 nerd-icons re-downloaded its font on every headless start.**
  `core.org` guarded `nerd-icons-install-fonts` with
  `(unless (member "Symbols Nerd Font Mono" (font-family-list)) …)`. With no
  display `font-family-list` returns `nil`, so the guard was always true and each
  run fetched ~2.5MB over the network.
  - **Evidence:** `use-package-compute-statistics` attributed **6.3s** to
    `nerd-icons`, and `~/Library/Fonts/NFM.ttf` carried a timestamp from the
    smoke-test runs minutes earlier.
  - **Also affected the GUI:** `Symbols Nerd Font Mono` was not installed at all
    (only `FiraCodeNerdFont*`), so the guard was true in graphical sessions too.
  - **Do:** added a `display-graphic-p` guard, and added
    `font-symbols-only-nerd-font` to `install.sh` so the family exists
    declaratively rather than being self-installed by Emacs.
  - **Result: init 4.2s → 0.9s** (4.6×), no network access at startup.
  - **Tested and rejected first:** `straight-check-for-modifications`
    `'(check-on-save find-when-checking)` made no difference (3.76s vs 3.69s).
    Individually `require`-ing every core package summed to 1.25s against core's
    3.39s — that gap is what pointed at instrumentation over guesswork.

- [x] **6.2 Module loading is now fault-isolated.** `Emacs.org` ran six bare
  `(load "…")` calls, so one bad form aborted every later module — the mechanism
  by which item 1.1 silently disabled `macos.el` and `extras.el`.
  - **Do:** `skls/load-module` wraps each `load` in `condition-case`, collects
    failures in `skls/module-load-errors`, and reports them once on
    `emacs-startup-hook`. `C-g` still aborts, since only `error` is caught.
  - **Verify:** injecting `(error "DELIBERATE TEST FAILURE")` into `files.el`
    produced `failed=("files") extras-loaded=t macos-ran="/opt/homebrew/bin/gls"`
    — the two modules after the failure both loaded. `files.el` was then restored
    by re-tangling and confirmed byte-identical.

- [x] **6.3 Hardcoded fonts, and an `install.sh` coverage gap.** `Fira Code`,
  `Cantarell` and `MesloLGS NF` were set unconditionally in four places.
  - **Correction to the earlier framing:** this is *not* the same failure class as
    6.1. Verified that `set-face-attribute` with a missing family does **not**
    signal an error — Emacs silently substitutes a default. So the risk is a
    frame that quietly looks wrong, not a broken module.
  - **The actual defect was in `install.sh`:** it installed
    `font-fira-code-nerd-font` (family `FiraCode Nerd Font`) but the config asks
    for `Fira Code`, which comes from the separate `font-fira-code` cask. Neither
    that nor any Meslo cask was ever installed by the script — both were present
    on this machine only because they were installed out of band (`MesloLGS NF`
    by powerlevel10k's font wizard, Feb 20). A fresh machine silently fell back
    for both the default face and vterm.
  - **Naming trap:** the `font-meslo-lg-nerd-font` cask ships
    `MesloLGSNerdFont-*.ttf` → family `MesloLGS Nerd Font`, **not** p10k's
    `MesloLGS NF`. Adding the cask alone would not have satisfied the config, so
    the vterm face now falls back across both names.
  - **Daemon trap:** `font-family-list` is empty with no GUI frame, which is the
    case during init under `--bg-daemon`. A naive `display-graphic-p` guard would
    therefore skip font setup entirely for the daemon. `skls/apply-fonts` runs
    both at load time and from `after-make-frame-functions`.
  - **Do:** added `skls/first-font` (returns the first available family, else nil)
    and `skls/apply-fonts`; removed the duplicate font line from `macos.org`,
    which set the default face a second time; guarded the vterm and org-heading
    faces; declared all five font casks in `install.sh`.
  - **Verify:** five stubbed unit tests over `skls/first-font` (first-wins,
    fallback, none-present→nil, vterm chain, no-display→nil) all pass;
    `after-make-frame-functions` contains `skls/apply-fonts`; init stays clean.
    **Still needs a GUI check** — batch cannot validate real font rendering.

## Third pass — build reproducibility & built-ins (2026-07-30)

- [x] **7.1 `install.sh` now pins the Emacs build.** Three defects in one block:
  no `--with-xwidgets` (so a fresh machine silently reverted grip to browser
  previews); a `brew list emacs-plus@30` guard that skipped machines already
  holding a non-xwidget build instead of correcting them; and
  `cp -r … /Applications/`, which fails outright once `/Applications/Emacs.app`
  is an alias, because `[[ ! -d ]]` is true for an alias file and `cp` cannot
  overwrite a non-directory with a directory — with `set -e` that aborted the
  whole install.
  - **Do:** detect the *feature* rather than the package —
    `emacs --batch --eval '(kill-emacs (if (featurep (quote xwidget-internal)) 0 1))'`
    — and `brew reinstall … --with-xwidgets` when absent. Replaced `cp -r` with
    an `osascript` Finder alias, which always resolves to the current Cellar
    build and so cannot go stale.
  - **Verify:** detection returns "has xwidgets → skip rebuild" on this machine,
    and a negative control (`featurep` of a nonexistent feature) correctly exits 1.

- [x] **7.2 Daemon under launchd.** `brew services list` showed
  `emacs-plus@30  none` — emacs-plus ships a service definition that was unused.
  The daemon had been started by hand, ran 13 days on a since-replaced binary,
  and was launched from a path that stopped resolving. `install.sh` now runs
  `brew services start d12frosted/emacs-plus/emacs-plus@30`; after an upgrade,
  `brew services restart emacs-plus@30` picks up the new build.
  - **Safe despite launchd's minimal PATH** because `macos.el` sets `exec-path`
    and `PATH` explicitly.

- [x] **7.3 Built-in modes enabled.** `save-place-mode`, `recentf-mode` (which is
  what the dashboard's `recents` section actually reads), `repeat-mode`,
  `global-so-long-mode`, plus real `savehist` configuration — `history-length`
  1000, `history-delete-duplicates`, and `savehist-additional-variables` for the
  kill ring and search rings.
  - **Verify:** `save-place=t recentf=t repeat=t so-long=t hist-len=1000`.

- [x] **7.4 `my-keys-minor-mode` replaced by `general`.** ~15 lines defining a
  minor mode, its keymap, and a `minibuffer-setup-hook` to switch itself off,
  all to win precedence over major modes — which `general-define-key` with
  `:keymaps 'override` does directly.
  - **Care taken:** wrapped in `with-eval-after-load 'general` rather than called
    at top level, so it does not depend on `general` being loaded at that point.
    (Checked first that `general` does in fact load and the leader keys work —
    `C-c a` → `org-agenda` — before touching any of it.)
  - **Verify:** all four `<M-C-arrow>` keys resolve to `windmove-*`,
    `my-keys-minor-mode` is gone, and `C-c a` still maps to `org-agenda`.

## Removed in this pass

Config deleted, repos purged: `ob-cypher` + the `cypher` babel language and `cy`
template, `ox-reveal`, `org-tree-slide`, `htmlize`, `realgud`, `poetry.el`,
`sphinx-doc`, `visual-fill-column` (→ `olivetti`), third-party `which-key`
(→ built-in), plus 41 orphaned clones including `copilot.el`, `company`,
`ivy`/`swiper`/`counsel-projectile`, `all-the-icons`, `python-mode`, `pyvenv`.

`sphinx-doc` was dropped on evidence rather than preference: across `~/github`,
**3** Python files use reST `:param:` docstrings versus **383** using
Google/NumPy `Args:` style, and there is no `conf.py` anywhere — no Sphinx builds
at all.

One extra anti-pattern found during execution, not in the original plan:
`sql-indent` was declared inside `(eval-after-load "sql" '(use-package …))`, so
it registered nothing until `sql` happened to load and therefore appeared in the
orphan list. Lifted to a top-level `use-package` with `:hook` *before* purging,
so it was correctly spared.

## Open decisions for Miguel

All resolved — see the status note at the top. Nothing is blocked.

## What is left

1. **Commit the working tree** (0.2) — nothing has been committed.
2. **Restart the Emacs daemon** so the new config is actually in memory; the
   daemon holds whatever it loaded at start.
4. **GUI-verify the font work (6.3)** — confirm the default face, org headings,
   and the vterm prompt all render correctly in a real frame, including a
   daemon-created one (`emacsclient -c`).
7. **2.3** built-in `editorconfig-mode` — optional, only if you want
   `.editorconfig` honored.
8. **5.3** macOS Spanish-character bindings shadowing standard keys — a
   deliberate trade-off to make explicit, not a bug.
9. **5.4** GUI-verify `(set-fringe-mode -1)`.
10. **Treesit** — available but no grammars installed; the `python-base-mode`
    change in 5.1 means adopting it is now safe whenever you want.
