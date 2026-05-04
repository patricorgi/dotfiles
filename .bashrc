#!/usr/bin/env bash

[[ $- != *i* ]] && return
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export X509_USER_PROXY=$HOME/.grid.proxy
# export HISTSIZE=10000
# export HISTFILESIZE=10000
# shopt -s histappend
# PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

[ -x "$(command -v ganga)" ] && export X509_USER_PROXY=$HOME/.grid.proxy
[ -f "$HOME/local.sh" ] && source "$HOME/local.sh"
[ -f "$HOME/dotfiles/bash/aliases" ] && source "$HOME/dotfiles/bash/aliases"
[ -f "$HOME/dotfiles/bash/functions" ] && source "$HOME/dotfiles/bash/functions"
[ -f "$HOME/dotfiles/bash/completes" ] && source "$HOME/dotfiles/bash/completes"

if [ -d "$HOME/.cargo/bin" ] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
	export PATH="$HOME/.cargo/bin:$PATH"
fi

_bash_cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
_bash_hook_cache_dir="$_bash_cache_home/bash"

_source_cached_hook() {
	local cache_name="$1"
	local command_path="$2"
	shift 2

	local cache_file="$_bash_hook_cache_dir/${cache_name}.bash"
	if [ ! -s "$cache_file" ] || [ "$command_path" -nt "$cache_file" ]; then
		mkdir -p "$_bash_hook_cache_dir" || return 1

		local tmp_file
		tmp_file=$(mktemp "$_bash_hook_cache_dir/${cache_name}.XXXXXX") || return 1
		if "$command_path" "$@" >"$tmp_file"; then
			mv "$tmp_file" "$cache_file"
		else
			rm -f "$tmp_file"
			return 1
		fi
	fi

	source "$cache_file"
}

# bash integration of cli tools
if direnv_bin=$(command -v direnv 2>/dev/null); then
	_source_cached_hook direnv "$direnv_bin" hook bash
fi
if starship_bin=$(command -v starship 2>/dev/null); then
	_source_cached_hook starship "$starship_bin" init bash
fi
if zoxide_bin=$(command -v zoxide 2>/dev/null); then
	_source_cached_hook zoxide "$zoxide_bin" init --cmd cd bash
fi
[ -x "$(command -v bat)" ] && export BAT_THEME="Catppuccin-mocha"

# FZF
if [ -x "$HOME/.fzf/bin/fzf" ]; then
	[[ ":$PATH:" != *":$HOME/.fzf/bin:"* ]] && export PATH="$PATH:$HOME/.fzf/bin"
	_source_cached_hook fzf "$HOME/.fzf/bin/fzf" --bash
fi
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
