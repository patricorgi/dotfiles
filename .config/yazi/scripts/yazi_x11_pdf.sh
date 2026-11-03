#!/usr/bin/env bash
set -u

# Yazi may outlive an SSH connection. Read X11 variables from the newest
# attached tmux client instead of using Yazi's stale environment.
if ! { [[ -n ${DISPLAY:-} ]] && xdpyinfo >/dev/null 2>&1; } \
  && [[ -n ${TMUX:-} ]]; then
  client_pid=$(tmux display-message -p '#{client_pid}' 2>/dev/null || true)
  client_pids=""
  [[ -n $client_pid ]] && client_pids="$client_pid"
  [[ -z $client_pids ]] && client_pids=$(tmux list-clients -F '#{client_activity} #{client_pid}' 2>/dev/null | sort -rn | cut -d' ' -f2-)

  while read -r client_pid; do
    [[ -n $client_pid ]] || continue
    [[ -r "/proc/$client_pid/environ" ]] || continue
    live_display=""
    live_xauthority=""
    while IFS= read -r -d '' entry; do
      case "$entry" in
        DISPLAY=*) live_display=${entry#DISPLAY=} ;;
        XAUTHORITY=*) live_xauthority=${entry#XAUTHORITY=} ;;
      esac
    done < "/proc/$client_pid/environ"
    if [[ -n $live_display ]]; then
      export DISPLAY="$live_display"
      [[ -n $live_xauthority ]] && export XAUTHORITY="$live_xauthority"
      break
    fi
  done <<< "$client_pids"
fi

if [[ -n ${SSH_CONNECTION:-} && -n ${DISPLAY:-} ]]; then
  for viewer in mupdf-gl zathura; do
    if command -v "$viewer" >/dev/null; then
      if [[ $viewer == mupdf-gl ]]; then
        exec "$viewer" -r 180 -A 8 "$@"
      fi
      exec "$viewer" "$@"
    fi
  done
fi

exec xdg-open "$@"
