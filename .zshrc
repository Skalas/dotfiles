# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/opt/homebrew/opt/libpq/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export NODE_OPTIONS="--disable-warning=DEP0040"
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(git docker docker-compose macos pip python brew ssh-agent vscode gnu-utils emacs)

source $ZSH/oh-my-zsh.sh

# Language
export LANG=en_US.UTF-8

# Powerlevel10k
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Shell customizations
source ~/src/skls/aliases
source ~/src/skls/python/conda_initialize.zsh
eval "$(direnv hook zsh)"

# Google Cloud SDK
if [ -f "${DOTFILES:-$HOME/github/skalas/dotfiles}/src/google-cloud-sdk/path.zsh.inc" ]; then
  source "${DOTFILES:-$HOME/github/skalas/dotfiles}/src/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "${DOTFILES:-$HOME/github/skalas/dotfiles}/src/google-cloud-sdk/completion.zsh.inc" ]; then
  source "${DOTFILES:-$HOME/github/skalas/dotfiles}/src/google-cloud-sdk/completion.zsh.inc"
fi

# iTerm2 integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Ruby
eval "$(rbenv init - zsh)"

# Docker completions
fpath=($HOME/.docker/completions $fpath)

# Kiro shell integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Fortune (after prompt setup to avoid breaking instant prompt)
fortune -s
