#!/usr/bin/env bash

# this setup script does not require root priviledge
# BUT it installs some programs in $HOME/.local/bin
# make sure to add this path in your PATH or change it as you wish
DOTFILES_DIR="$HOME/dotfiles"
LOCAL_PREFIX="$HOME/.local"
INSTALLDIR="$LOCAL_PREFIX/bin"
OS_NAME=$(uname -s)
ARCH_NAME=$(uname -m)
MAKE_JOBS=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 1)

has_cmd() {
	command -v "$1" >/dev/null 2>&1
}

link_if_missing() {
	[ -e "$2" ] || [ -L "$2" ] || ln -s "$1" "$2"
}

cargo_install_if_missing() {
	local command_name="$1"
	local crate_name="$2"
	shift 2
	has_cmd "$command_name" || cargo install "$crate_name" "$@"
}

version_lt() {
	local IFS=.
	local left=($1)
	local right=($2)
	local i

	for ((i = ${#left[@]}; i < ${#right[@]}; i++)); do
		left[i]=0
	done
	for ((i = ${#right[@]}; i < ${#left[@]}; i++)); do
		right[i]=0
	done

	for ((i = 0; i < ${#left[@]}; i++)); do
		if ((10#${left[i]} < 10#${right[i]})); then
			return 0
		elif ((10#${left[i]} > 10#${right[i]})); then
			return 1
		fi
	done

	return 1
}

# basic requirements
# if [ ! -x "$(command -v fusermount)" ]; then
# 	echo "fusermount is required to run .appimage"
# 	echo "Exiting..."
# 	exit 1
# fi
if ! has_cmd curl; then
	echo "curl is required for pulling pre-compiled binaries from git release page"
	echo "Exiting..."
	exit 1
fi

# create symlinks of my dotfiles (will not override if already exists)
if [ -d "$HOME/.config" ]; then
	for src in "$DOTFILES_DIR"/.config/*; do
		[ -e "$src" ] || continue
		link_if_missing "$src" "$HOME/.config/$(basename "$src")"
	done
else
	ln -s "$DOTFILES_DIR/.config" "$HOME/.config"
fi
link_if_missing "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_if_missing "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link_if_missing "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
link_if_missing "$DOTFILES_DIR/.inputrc" "$HOME/.inputrc"
[ -d "$HOME/.fzf" ] || (git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install")

# installations of all the tools I need
has_cmd cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
mkdir -p "$INSTALLDIR" "$LOCAL_PREFIX/share" "$LOCAL_PREFIX/lib"
export PATH="$HOME/.cargo/bin:$INSTALLDIR:$PATH"
has_cmd starship || curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$INSTALLDIR"
cargo_install_if_missing rg ripgrep
cargo_install_if_missing zoxide zoxide
cargo_install_if_missing eza eza
cargo_install_if_missing fd fd-find
cargo_install_if_missing dust du-dust
has_cmd yazi || cargo install --force yazi-build
if ! has_cmd lazygit; then
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v0.45.2/lazygit_0.45.2_${OS_NAME}_${ARCH_NAME}.tar.gz"
	mkdir lazygit
	tar -xvf lazygit.tar.gz -C lazygit
	mv lazygit/lazygit "$INSTALLDIR"
	rm -r lazygit lazygit.tar.gz
fi

# install neovim which is compiled for older systems
# if your system is relatively new, you can install it from:
# https://github.com/neovim/neovim/releases/tag/stable
if ! has_cmd nvim; then
	curl -Lo nvim.tar.gz https://github.com/neovim/neovim-releases/releases/download/stable/nvim-linux-x86_64.tar.gz
	tar -xzf nvim.tar.gz
	cd nvim-linux-x86_64
	/bin/cp -rf bin/* "$INSTALLDIR/"
	/bin/cp -rf share/* "$LOCAL_PREFIX/share"
	/bin/cp -rf lib/* "$LOCAL_PREFIX/lib"
	cd ..
	rm -rf nvim-linux-x86_64 nvim.tar.gz
fi

# install tmux>=3.3 for allow-passthrough option
tmux_version="0"
if has_cmd tmux; then
	tmux_version=$(tmux -V | awk '{print $2}')
	if [[ ! ${tmux_version: -1} =~ [0-9] ]]; then
		tmux_version="${tmux_version::-1}"
	fi
fi
if version_lt "$tmux_version" "3.3"; then
	curl -Lo tmux-3.5a.tar.gz https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz
	tar -xvzf tmux-3.5a.tar.gz
	cd tmux-3.5a
	if pkg-config --cflags --libs libevent &>/dev/null; then
		./configure --prefix="$LOCAL_PREFIX" && make -j"$MAKE_JOBS"
	elif PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LOCAL_PREFIX/lib/pkgconfig" pkg-config --cflags --libs libevent &>/dev/null; then
		./configure --prefix="$LOCAL_PREFIX" CFLAGS="-I$LOCAL_PREFIX/include" LDFLAGS="-L$LOCAL_PREFIX/lib" && make -j"$MAKE_JOBS"
	else
		curl -Lo libevent.tar.gz https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
		tar -xvzf libevent.tar.gz
		cd libevent
		mkdir build && cd build
		cmake .. -DCMAKE_INSTALL_PREFIX="$LOCAL_PREFIX"
		make -j"$MAKE_JOBS"
		make install
		cd ../..
		./configure --prefix="$LOCAL_PREFIX" CFLAGS="-I$LOCAL_PREFIX/include" LDFLAGS="-L$LOCAL_PREFIX/lib" && make -j"$MAKE_JOBS"
	fi
	make install
	cd ..
	rm -rf tmux-3.5a tmux-3.5a.tar.gz
	echo "$(tmux -V) has been installed!"
fi
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# install direnv
if ! has_cmd direnv; then
	curl -sfL https://direnv.net/install.sh | bin_path="$INSTALLDIR" bash
fi

# tmux seems to be superior than xclip in terms of syncing up clipboards
# # install xclip
# if [ ! -x "$(command -v xclip)" ]; then
# 	wget https://sourceforge.net/projects/xclip/files/latest/download -O xclip.tar.gz
# 	tar -xzf xclip.tar.gz
# 	cd xclip-*
# 	./configure --prefix=$HOME/.local
# 	make && make install
# 	cd ..
# 	rm -rf xclip.tar.gz xclip-*
# fi

# finalize
echo "Setup complete. Open a new shell to pick up PATH changes."
