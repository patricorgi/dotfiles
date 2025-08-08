#!/bin/bash
macro="$1"

# Extract function name from file (e.g., h_mjpsipi2h.C → h_mjpsipi2h)
funcname=$(basename "$macro" .C)

# Launch ROOT and keep GUI alive
root -l <<EOF
gROOT->LoadMacro("$macro");
$funcname();
gApplication->Run();
EOF
