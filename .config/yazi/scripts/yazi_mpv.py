#!/usr/bin/env python3
"""Keep one macOS mpv player warm for the lifetime of its owning Yazi process.

Requires mpv and standard-library Python only. Hiding/detaching Yazi leaves the
player alive; exiting Yazi stops it. q saves playback and returns it to idle;
explicitly quitting the player restarts it on the next open.
"""

import json
import os
from pathlib import Path
import socket
import sys


def session_directory():
    session = os.environ.get("YAZI_ID", "")
    if not session.isdecimal():
        raise RuntimeError("Run this opener from Yazi (YAZI_ID is missing).")
    temporary = os.environ.get("TMPDIR")
    if not temporary or not os.path.isdir(temporary):
        import tempfile

        temporary = tempfile.gettempdir()
    directory = Path(os.path.abspath(temporary)) / f"yazi-mpv-{session}"
    directory.mkdir(mode=0o700, exist_ok=True)
    if directory.is_symlink() or directory.stat().st_uid != os.getuid():
        raise RuntimeError(f"Unsafe mpv session directory: {directory}")
    directory.chmod(0o700)
    return directory


def stop_on_signal(_signum, _frame):
    raise SystemExit(0)


def supervise(directory, owner):
    from contextlib import closing
    import fcntl
    import select
    import signal
    import subprocess

    ipc_path = directory / "ipc"
    lock_path = directory / "lock"
    with lock_path.open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        # A previous supervisor may have removed its lock just before we acquired it.
        if not lock_path.exists() or lock_path.stat().st_ino != os.fstat(lock.fileno()).st_ino:
            return

        player = None
        lifetime, inherited = socket.socketpair()
        signal.signal(signal.SIGTERM, stop_on_signal)
        signal.signal(signal.SIGHUP, stop_on_signal)
        try:
            with closing(select.kqueue()) as events:
                # Watch the actual process, so detaching tmux does not stop the player.
                events.control(
                    [
                        select.kevent(
                            owner,
                            filter=select.KQ_FILTER_PROC,
                            flags=select.KQ_EV_ADD | select.KQ_EV_ONESHOT,
                            fflags=select.KQ_NOTE_EXIT,
                        ),
                        select.kevent(
                            lifetime.fileno(), filter=select.KQ_FILTER_READ, flags=select.KQ_EV_ADD
                        ),
                    ],
                    0,
                    0,
                )
                ipc_path.unlink(missing_ok=True)
                player = subprocess.Popen(
                    [
                        "mpv",
                        "--idle=yes",
                        "--force-window=no",
                        "--terminal=no",
                        "--input-terminal=no",
                        "--focus-on=all",
                        "--vo=gpu-next",
                        "--hwdec=auto",
                        f"--script={Path(__file__).with_suffix('.lua')}",
                        f"--input-ipc-server={ipc_path}",
                        f"--input-ipc-client=fd://{inherited.fileno()}",
                    ],
                    pass_fds=(inherited.fileno(),),
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                inherited.close()
                if player.poll() is None:
                    try:
                        events.control(
                            [
                                select.kevent(
                                    player.pid,
                                    filter=select.KQ_FILTER_PROC,
                                    flags=select.KQ_EV_ADD | select.KQ_EV_ONESHOT,
                                    fflags=select.KQ_NOTE_EXIT,
                                ),
                            ],
                            0,
                            0,
                        )
                    except ProcessLookupError:
                        return
                    while True:
                        for event in events.control(None, 3, None):
                            if event.filter == select.KQ_FILTER_PROC:
                                return
                            # Drain unsolicited IPC events from the lifetime connection.
                            if not lifetime.recv(65536):
                                return
        finally:
            # mpv also quits on EOF here if this supervisor is killed unexpectedly.
            inherited.close()
            lifetime.close()
            if player is not None:
                try:
                    player.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    player.terminate()
                    try:
                        player.wait(timeout=1)
                    except subprocess.TimeoutExpired:
                        player.kill()
                        player.wait()
            ipc_path.unlink(missing_ok=True)
            lock_path.unlink(missing_ok=True)
            try:
                directory.rmdir()
            except OSError:
                pass


def connect(directory):
    connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    connection.settimeout(5)
    try:
        connection.connect(str(directory / "ipc"))
    except OSError:
        connection.close()
        return None
    return connection


def open_files(directory, owner, files):
    connection = connect(directory)
    if connection is None:
        import subprocess
        import time

        for _ in range(2):
            subprocess.Popen(
                [sys.executable, "-S", str(Path(__file__).resolve()), "--start", "--owner", str(owner)],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
            deadline = time.monotonic() + 2.5
            while time.monotonic() < deadline:
                connection = connect(directory)
                if connection is not None:
                    break
                time.sleep(0.02)
            if connection is not None:
                break
    if connection is None:
        raise RuntimeError("mpv did not start; check that mpv is installed and can open a window.")

    commands = [
        ["loadfile", str(Path(path).absolute()), "replace" if index == 0 else "append"]
        for index, path in enumerate(files)
    ]
    commands.extend(
        [
            ["set_property", "pause", False],
            ["set_property", "window-minimized", False],
        ]
    )
    with connection, connection.makefile("rb") as ipc:
        # Pipeline requests, but bound batches so large playlists cannot fill both sockets.
        for offset in range(0, len(commands), 32):
            batch = commands[offset : offset + 32]
            connection.sendall(
                b"".join(
                    (json.dumps({"command": command, "request_id": request_id}) + "\n").encode()
                    for request_id, command in enumerate(batch, offset + 1)
                )
            )
            pending = set(range(offset + 1, offset + len(batch) + 1))
            while pending:
                line = ipc.readline()
                if not line:
                    raise RuntimeError("mpv closed its IPC connection.")
                response = json.loads(line)
                request_id = response.get("request_id")
                if request_id not in pending:
                    continue
                if response.get("error") != "success":
                    raise RuntimeError(f"mpv: {response.get('error')}: {commands[request_id - 1][0]}")
                pending.remove(request_id)


def main():
    # Yazi supplies an explicit separator, so the hot path needs no CLI parser.
    if sys.argv[1:2] == ["--"]:
        start, owner, files = False, os.getppid(), sys.argv[2:]
    else:
        import argparse

        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument("--start", action="store_true", help="Prewarm the session's player")
        parser.add_argument("--owner", type=int, default=os.getppid(), help=argparse.SUPPRESS)
        parser.add_argument("files", nargs="*")
        args = parser.parse_args()
        start, owner, files = args.start, args.owner, args.files
    if not start and not files:
        raise RuntimeError("Provide at least one video file.")
    if sys.platform != "darwin":
        raise RuntimeError("This session player uses macOS process-exit notifications.")
    directory = session_directory()
    if start:
        supervise(directory, owner)
    else:
        open_files(directory, owner, files)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError) as error:
        print(f"yazi-mpv: {error}", file=sys.stderr)
        sys.exit(1)
