#!/usr/bin/env bash

[[ $- != *i* ]] && return
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgreprc
export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR

[ -f "$HOME/dotfiles/local.sh" ] && source "$HOME/dotfiles/local.sh"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/.config/nvm" ] && export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
[ -f "$HOME/dotfiles/bash/aliases" ] && source $HOME/dotfiles/bash/aliases
[ -f "$HOME/dotfiles/bash/functions" ] && source $HOME/dotfiles/bash/functions

[ -x "$(command -v starship)" ] && eval "$(starship init bash)"
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init --cmd cd bash)"
[ -x "$(command -v bat)" ] && export BAT_THEME="Catppuccin-mocha"

# TODO: organizing complete settings
complete -f -X '*.@(tex|bk|pdf|yaml|log|root|joblib)' p python python3
complete -f -X '*.@(pdf|yaml|log|joblib|py)' rl root
complete -f -X '*.@(root|joblib|py|yaml|sh|digi|log|cpp|h)' xo
complete -f -X '*.@(o|so|so.!(conf|*/*)|a|[rs]pm|gif|jp?(e)g|mp3|mp?(e)g|avi|asf|ogg|class|foo|bar|pdf)' v vi vim gvim rvim view rview rgvim rgview gview

# FZF
export FZF_DEFAULT_COMMAND="rg --files"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview ""' # disable FZF preview
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
bind "$(bind -s | command grep '^"\\ec"' | sed 's/ec/ed/')"
[[ $- =~ i ]] && bind '"\ec": nop'
