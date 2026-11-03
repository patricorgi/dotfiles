#!/usr/bin/env bash
# Open the persistent Yazi instance for this directory on an isolated tmux server.
set -euo pipefail

for tool in tmux yazi openssl od tr cut; do
	command -v "$tool" >/dev/null 2>&1 || {
		printf 'Required command not found: %s\n' "$tool" >&2
		exit 1
	}
done

cd "${1:-$PWD}"
directory=$(pwd -P)
private_config="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/tmux_yazi_private.conf"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
key_file="$config_dir/yazi-session-key"

if [[ ! -e $key_file ]]; then
	(umask 077; mkdir -p "$config_dir"; openssl rand -hex 32 > "$key_file")
fi
[[ -f $key_file && -r $key_file ]] || {
	printf 'Yazi session key is not readable: %s\n' "$key_file" >&2
	exit 1
}

# The private key prevents session names from revealing or being correlated with paths.
session="yazi-$(printf '%s' "$directory" \
	| openssl dgst -sha256 -mac HMAC -macopt "key:file:$key_file" -binary \
	| od -An -tx1 | tr -d ' \n' | cut -c1-24)"

if ! tmux -L yazi-private has-session -t "=$session" 2>/dev/null; then
	# tmux inherits this client's working directory; never put it in argv.
	# Attach the terminal before Yazi starts its terminal-capability queries.
	exec env -u TMUX tmux -L yazi-private -f "$private_config" \
		new-session -A -s "$session" -n yazi \
		env -u TMUX "YAZI_PRIVATE_SESSION=$session" yazi
fi

# Clear TMUX so attaching from the popup is not treated as a nested tmux session.
exec env -u TMUX tmux -L yazi-private attach-session -t "=$session"
