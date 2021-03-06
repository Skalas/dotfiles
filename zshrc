# Environment
source ~/dotfiles/env

# Alias
source ~/dotfiles/aliases


##############################
##
## Antigen
##
##############################

source ~/software/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle colored-man-pages

antigen bundle docker
antigen bundle dirhistory
antigen bundle git-extras
antigen bundle tmux
antigen bundle httpie
antigen bundle jsontools
antigen bundle pep8
antigen bundle pyenv
antigen bundle python
antigen bundle web-search

# Themes
antigen bundle tylerreckart/odin
antigen bundle tylerreckart/hyperzsh


# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle mafredri/zsh-async
antigen bundle marszall87/lambda-pure


# Themes
#antigen theme geometry-zsh/geometry
#antigen theme tylerreckart/odin odin.zsh-theme
#antigen theme https://github.com/denysdovhan/spaceship-zsh-theme spaceship
#antigen theme tylerreckart/hyperzsh hyperzsh.zsh-theme

antigen apply

ZSH_TMUX_AUTOSTART=true



#source ~/dotfiles/spaceship-theme.cfg

