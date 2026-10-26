#!/usr/bin/env bash
set -euo pipefail

macro=${1:?ROOT macro path is required}
output=${2:?preview output path is required}

# Only execute macros ROOT generated from a canvas. Handwritten .C files may
# perform fits, modify data, or submit work and should remain code previews.
if ! rg -q '^//=========Macro generated from canvas:' "$macro"; then
  printf 'Not a ROOT-generated canvas macro: %s\n' "$macro" >&2
  exit 3
fi

export YAZI_ROOT_PREVIEW_MACRO=$macro
export YAZI_ROOT_PREVIEW_OUTPUT=$output

root_args=(
  -l
  -b
  -q
  -e
  'TString path(gSystem->Getenv("YAZI_ROOT_PREVIEW_MACRO")); TString output(gSystem->Getenv("YAZI_ROOT_PREVIEW_OUTPUT")); Int_t error = 0; gROOT->Macro(path.Data(), &error); if (error) { Error("yazi_root_preview", "Failed to load %s", path.Data()); gSystem->Exit(error); } auto canvas = (TCanvas*)gROOT->GetListOfCanvases()->Last(); if (!canvas) { Error("yazi_root_preview", "No canvas was created by %s", path.Data()); gSystem->Exit(2); } canvas->Update(); canvas->SaveAs(output.Data());'
)

if command -v root.exe >/dev/null 2>&1; then
  exec root.exe "${root_args[@]}"
elif command -v root >/dev/null 2>&1; then
  exec root "${root_args[@]}"
elif [[ -r /cvmfs/lhcb.cern.ch/lib/LbEnv ]]; then
  set +u
  source /cvmfs/lhcb.cern.ch/lib/LbEnv --sh
  set -u
  exec lb-conda default env \
    "YAZI_ROOT_PREVIEW_MACRO=$macro" \
    "YAZI_ROOT_PREVIEW_OUTPUT=$output" \
    root "${root_args[@]}"
else
  printf 'ROOT is unavailable and LHCb CVMFS is not mounted\n' >&2
  exit 127
fi
