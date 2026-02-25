#!/usr/bin/env bash
# Tangle all Org files to generate config files (.el, .gitconfig, etc.).
# Run this once after cloning, before `stow -t ~ .`.

set -e
cd "$(dirname "$0")"

for f in Emacs.org emacs/*.org yasnippets.org git.org ssh.org zsh.org; do
  if [ -f "$f" ]; then
    echo "Tangling $f ..."
    emacs --batch -l org --eval "(org-babel-tangle-file \"$f\")"
  fi
done

echo "Done. Now run: stow -t ~ ."
