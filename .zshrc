fortune -s 
if command -v direnv &>/dev/null; then
  export DIRENV_LOG_FORMAT=""
  eval "$(direnv hook zsh)"
fi

# Auto-start tmux (must be before everything else)
if command -v tmux &>/dev/null && [[ -z "$TMUX" && -z "$EMACS" && -z "$INSIDE_EMACS" && $- == *i* ]]; then
  tmux new-session -A -s main && return
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
[[ "$(uname -s)" == Darwin ]] && export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(git docker docker-compose pip python ssh-agent emacs)
[[ "$(uname -s)" == Darwin ]] && plugins+=(macos brew gnu-utils)

source $ZSH/oh-my-zsh.sh

# Language
export LANG=en_US.UTF-8

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Shell customizations
[[ -f ~/src/skls/aliases ]] && source ~/src/skls/aliases


# Machine-specific config (not tracked in dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
