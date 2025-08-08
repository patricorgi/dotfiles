#!/usr/bin/env bash

[[ $- != *i* ]] && return
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export X509_USER_PROXY=$HOME/.grid.proxy
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

[ -x "$(command -v ganga)" ] && export X509_USER_PROXY=$HOME/.grid.proxy
[ -f "$HOME/local.sh" ] && source "$HOME/local.sh"
[ -f "$HOME/dotfiles/bash/aliases" ] && source "$HOME/dotfiles/bash/aliases"
[ -f "$HOME/dotfiles/bash/functions" ] && source "$HOME/dotfiles/bash/functions"
[ -f "$HOME/dotfiles/bash/completes" ] && source "$HOME/dotfiles/bash/completes"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# bash integration of cli tools
[ -x "$(command -v direnv)" ] && eval "$(direnv hook bash)"
[ -x "$(command -v starship)" ] && eval "$(starship init bash)"
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init --cmd cd bash)"
[ -x "$(command -v bat)" ] && export BAT_THEME="Catppuccin-mocha"

# FZF
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgreprc
export FZF_DEFAULT_COMMAND="rg --files"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview "head {}"' # disable FZF preview
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
bind "$(bind -s | command grep '^"\\ec"' | sed 's/ec/ed/')"
[[ $- =~ i ]] && bind '"\ec": nop'

# [ -d "$HOME/.config/nvm" ] && export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
