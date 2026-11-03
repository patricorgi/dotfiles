#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

# Use the display environment of the active tmux client, rather than a stale
# tmux-server DISPLAY value after an SSH reconnect.
if [[ -n ${SSH_CONNECTION:-} && -n ${TMUX:-} ]]; then
  while IFS= read -r client_pid; do
    [[ -r "/proc/$client_pid/environ" ]] || continue
    while IFS= read -r -d '' entry; do
      case "$entry" in
        DISPLAY=*) export DISPLAY=${entry#DISPLAY=} ;;
        XAUTHORITY=*) export XAUTHORITY=${entry#XAUTHORITY=} ;;
      esac
    done < "/proc/$client_pid/environ"
    [[ -n ${DISPLAY:-} ]] && break
  done < <(tmux list-clients -F '#{client_pid}' 2>/dev/null)
fi

[[ $# -eq 1 ]] || { printf 'Expected one ROOT macro path\n' >&2; exit 2; }

YAZI_ROOT_HELPERS_DIR="$script_dir" YAZI_NO_PULL_MACRO="$1" root.exe -l -e '
  gInterpreter->Declare("void yazi_root_canvas_closed() { gROOT->SetInterrupt(); }");
  const char *helpersDir = gSystem->Getenv("YAZI_ROOT_HELPERS_DIR");
  if (!helpersDir) gSystem->Exit(2);
  gROOT->LoadMacro(Form("%s/display_without_pull.C", helpersDir));
  display_without_pull(gSystem->Getenv("YAZI_NO_PULL_MACRO"));
  int canvases = 0;
  TIter next(gROOT->GetListOfCanvases());
  while (auto canvas = (TCanvas*)next()) {
    canvas->Connect("Closed()", 0, 0, "yazi_root_canvas_closed()");
    ++canvases;
  }
  while (canvases > 0 && !gSystem->ProcessEvents()) gSystem->Sleep(100);
'
