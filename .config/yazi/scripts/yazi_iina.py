#!/usr/bin/env python3
"""Open videos in the running IINA instance without launching another app process."""

import os
from pathlib import Path
import sys
from urllib.parse import urlencode


def open_files(files):
    if not files:
        raise RuntimeError("Provide at least one video file.")
    paths = [Path(path).absolute() for path in files]
    if len(paths) == 1:
        query = urlencode({"url": paths[0].as_uri(), "new_window": "0", "mpv_pause": "no"})
        args = ["open", f"iina://open?{query}"]
    else:
        # One native multi-file request preserves playlist order without URL-event races.
        args = ["open", "-a", "IINA", *(str(path) for path in paths)]
    os.execv("/usr/bin/open", args)


if __name__ == "__main__":
    files = sys.argv[2:] if sys.argv[1:2] == ["--"] else sys.argv[1:]
    try:
        open_files(files)
    except (OSError, RuntimeError) as error:
        print(f"yazi-iina: {error}", file=sys.stderr)
        sys.exit(1)
