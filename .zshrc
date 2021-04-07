fortune -s

source ~/src/antigen.zsh
# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle docker
antigen bundle dirhistory
antigen bundle git-extras
antigen bundle tmux
antigen bundle httpie
antigen bundle jsontools
antigen bundle pep8
antigen bundle python
antigen bundle aws
antigen bundle esc/conda-zsh-completion

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle ssh-agent

if [[ $CURRENT_OS == 'OS X' ]]; then
    antigen bundle brew
    antigen bundle brew-cask
    antigen bundle gem
    antigen bundle osx
elif [[ $CURRENT_OS == 'Linux' ]]; then

    if [[ $DISTRO == 'CentOS' ]]; then
        antigen bundle centos
    fi
elif [[ $CURRENT_OS == 'Cygwin' ]]; then
    antigen bundle cygwin
fi
# Load the theme.
antigen theme juanghurtado

# Tell Antigen that you're done.
antigen apply

source ~/src/skls/wsl.zsh
source ~/src/skls/vterm.zsh
source ~/src/skls/python/poetry.zsh
source ~/src/skls/aliases
source ~/src/livenation.sh
source ~/.env_vars
#source ~/src/skls/python/conda_initialize.zsh
source ~/src/skls/python/pyenv.zsh
# Alias
source ~/src/skls/aliases
