#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

# Use the live tmux client environment: Yazi and tmux's global environment can
# retain an expired X11 forwarding display after an SSH reconnect.
if [[ -n ${SSH_CONNECTION:-} && -n ${TMUX:-} ]]; then
  live_display=""
  live_xauthority=""
  while IFS= read -r client_pid; do
    [[ -r "/proc/$client_pid/environ" ]] || continue
    while IFS= read -r -d '' entry; do
      case "$entry" in
        DISPLAY=*) live_display=${entry#DISPLAY=} ;;
        XAUTHORITY=*) live_xauthority=${entry#XAUTHORITY=} ;;
      esac
    done < "/proc/$client_pid/environ"
    [[ -n $live_display ]] && break
  done < <(tmux list-clients -F '#{client_pid}' 2>/dev/null)

  [[ -n $live_display ]] && export DISPLAY="$live_display"
  [[ -n $live_xauthority ]] && export XAUTHORITY="$live_xauthority"
fi

# Background Yazi tasks have no interactive stdin, so process X11 events
# without entering ROOT's interactive command loop.
if YAZI_ROOT_HELPERS_DIR="$script_dir" YAZI_ROOT_MACROS="$(printf '%s\n' "$@")" root.exe -l -e 'gInterpreter->Declare("void yazi_root_canvas_closed() { gROOT->SetInterrupt(); } void yazi_scale_exotic_pdfs(TPad *pad, bool z, bool zk, double scale) { TIter next(pad->GetListOfPrimitives()); while (auto object = next()) { if (object->InheritsFrom(TPad::Class())) yazi_scale_exotic_pdfs((TPad*)object, z, zk, scale); if (!object->InheritsFrom(TH1::Class())) continue; TString name(object->GetName()); if ((z && name.BeginsWith(\"f_rZ_\")) || (zk && name.BeginsWith(\"f_rZK_\"))) ((TH1*)object)->Scale(scale); } }"); TString macros(gSystem->Getenv("YAZI_ROOT_MACROS")); bool scale_exotics = TString(gSystem->Getenv("YAZI_SCALE_EXOTICS")).Length() > 0; double exotic_scale = TString(gSystem->Getenv("YAZI_SCALE_EXOTICS")).Atof(); auto entries = macros.Tokenize("\n"); int failures = 0; int canvases = 0; for (int index = 0; index < entries->GetEntriesFast(); ++index) { auto path = ((TObjString*)entries->At(index))->GetString(); int canvas_count = gROOT->GetListOfCanvases()->GetSize(); Int_t error = 0; gROOT->Macro(path.Data(), &error); if (error) { Error("yazi_root", "Failed to load %s", path.Data()); ++failures; continue; } bool z = path.Contains("mjpsipi"); bool zk = path.Contains("mjpsik"); TString title(gSystem->BaseName(path)); int seen = 0; TIter next(gROOT->GetListOfCanvases()); while (auto canvas = (TCanvas*)next()) { if (seen++ >= canvas_count) { if (scale_exotics && (z || zk)) { yazi_scale_exotic_pdfs(canvas, z, zk, exotic_scale); canvas->Modified(); } canvas->SetTitle(title.Data()); canvas->Connect("Closed()", 0, 0, "yazi_root_canvas_closed()"); ++canvases; } } } delete entries; if (failures) gSystem->Exit(1); while (canvases > 0 && !gSystem->ProcessEvents()) gSystem->Sleep(100);'; then
  exit 0
else
  status=$?
fi

if [[ -n ${TMUX:-} ]]; then
  tmux display-message "ROOT failed (exit $status): ${1##*/}"
else
  printf 'ROOT failed (exit %s): %s\n' "$status" "${1##*/}" >&2
fi
exit "$status"
