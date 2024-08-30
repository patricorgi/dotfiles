#!/bin/bash

# set -e

# symlinks
[ -d "$HOME/.config" ] && ln -s $HOME/dotfiles/.config/* $HOME/.config || ln -s $HOME/dotfiles/.config $HOME
[ -f "$HOME/.tmux.conf" ] || ln -s $HOME/dotfiles/.tmux.conf $HOME/.tmux.conf
[ -f "$HOME/.bashrc" ] || ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc
[ -f "$HOME/.bash_profile" ] || ln -s $HOME/dotfiles/.bash_profile $HOME/.bash_profile
[ -f "$HOME/.inputrc" ] || ln -s $HOME/dotfiles/.inputrc $HOME/.inputrc
[ -d "$HOME/.fzf" ] || (git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install)

# installations
[ -x "$(command -v cargo)" ] || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
[ -x "$(command -v starship)" ] || curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir $HOME/.local/bin
[ -x "$(command -v rg)" ] || cargo install ripgrep
[ -x "$(command -v zoxide)" ] || cargo install zoxide
[ -x "$(command -v eza)" ] || cargo install eza
[ -x "$(command -v fd)" ] || cargo install fd-find
[ -x "$(command -v dust)" ] || cargo install du-dust
[ -x "$(command -v yazi)" ] || cargo install --locked yazi-fm yazi-cli
if [ ! -x "$(command -v lazygit)" ]; then
	curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.43.1/lazygit_0.43.1_$(uname -s)_$(uname -m).tar.gz
	tar -xvf lazygit.tar.gz
	mv lazygit $HOME/.local/bin
fi
tmux_version=$(tmux -V | awk '{print $2}')
if [[ ! ${tmux_version: -1} =~ [0-9] ]]; then
	tmux_version="${tmux_version::-1}"
fi
if (($(echo "$tmux_version < 3.3" | bc -l))); then
	curl -Lo tmux.appimage https://github.com/nelsonenzo/tmux-appimage/releases/download/3.3a/tmux.appimage
	chmod +x tmux.appimage
	mv tmux.appimage $HOME/.local/bin/tmux
fi

# install xclip
if [ ! -x "$(command -v xclip)" ]; then
	wget https://sourceforge.net/projects/xclip/files/latest/download -O xclip.tar.gz
	tar -xzf xclip.tar.gz
	cd xclip-*
	./configure --prefix=$HOME/.local
	make && make install
	cd ..
	rm -rf xclip.tar.gz xclip-*
fi

# install direnv
if [ ! -x "$(command -v direnv)" ]; then
	export bin_path=~/.local/bin
	curl -sfL https://direnv.net/install.sh | bash
fi

# finalize
source $HOME/.bashrc
