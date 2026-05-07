#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
	echo "Usage: run_root_macro.sh <file.C>" >&2
	exit 1
fi

macro="$1"

if [ ! -f "$macro" ]; then
	echo "File not found: $macro" >&2
	exit 1
fi

if [ "$(uname)" = "Darwin" ] && [ -x "$(command -v osascript)" ]; then
	osascript \
		-e 'on run argv' \
		-e 'display notification ("Opening " & (item 1 of argv)) with title "ROOT GUI"' \
		-e 'end run' \
		"$(basename "$macro")" >/dev/null 2>&1 || true
fi

macro_dir=$(cd "$(dirname "$macro")" && pwd -P)
macro_abs="$macro_dir/$(basename "$macro")"

root_bin=$(dirname "$(command -v root)")
python_bin="$root_bin/python3"
if [ ! -x "$python_bin" ]; then
	python_bin=$(command -v python3)
fi

exec "$python_bin" - "$macro_abs" <<'PY'
import ctypes
import os
import sys
from time import monotonic, sleep

import ROOT


objc = ctypes.CDLL("/usr/lib/libobjc.A.dylib")
ctypes.CDLL("/System/Library/Frameworks/AppKit.framework/AppKit")
objc.objc_getClass.restype = ctypes.c_void_p
objc.objc_getClass.argtypes = [ctypes.c_char_p]
objc.sel_registerName.restype = ctypes.c_void_p
objc.sel_registerName.argtypes = [ctypes.c_char_p]


def objc_msg(receiver, selector, restype=ctypes.c_void_p, *args):
    send = objc.objc_msgSend
    send.restype = restype
    send.argtypes = [ctypes.c_void_p, ctypes.c_void_p] + [type(arg) for arg in args]
    return send(receiver, objc.sel_registerName(selector.encode()), *args)


def visible_cocoa_window_count():
    app_class = objc.objc_getClass(b"NSApplication")
    app = objc_msg(app_class, "sharedApplication")
    windows = objc_msg(app, "windows")
    count = objc_msg(windows, "count", ctypes.c_ulong)
    visible = 0

    for index in range(count):
        window = objc_msg(windows, "objectAtIndex:", ctypes.c_void_p, ctypes.c_ulong(index))
        if objc_msg(window, "isVisible", ctypes.c_bool):
            visible += 1

    return visible


macro_path = os.path.abspath(sys.argv[1])

ROOT.gROOT.SetWebDisplay("off")
ROOT.gROOT.Macro(macro_path)

visible_windows = visible_cocoa_window_count()
canvases = ROOT.gROOT.GetListOfCanvases()
has_canvases = bool(canvases and canvases.GetSize() > 0)

if visible_windows == 0 and not has_canvases:
    sys.exit(0)

window_was_visible = visible_windows > 0
startup_deadline = monotonic() + 30

while True:
    if ROOT.gROOT.IsInterrupted() or ROOT.gSystem.ProcessEvents():
        break

    visible_windows = visible_cocoa_window_count()
    if visible_windows > 0:
        window_was_visible = True
    elif window_was_visible or monotonic() > startup_deadline:
        break

    sleep(0.05)
PY
