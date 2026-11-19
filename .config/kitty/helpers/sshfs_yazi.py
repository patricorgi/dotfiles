"""Open local Yazi at the focused workspace pane's SSHFS directory."""

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import threading
import time
from concurrent.futures import Future

from kittens.tui.handler import result_handler

SSHFS_TYPES = {"macfuse", "osxfuse", "sshfs", "fuse.sshfs"}


def main(args):
    pass


def mount_at(directory):
    result = subprocess.run(["/sbin/mount"], capture_output=True, text=True, check=True, timeout=5)
    for line in result.stdout.splitlines():
        entry, sep, options = line.rpartition(" (")
        source, marker, target = entry.rpartition(" on ")
        if sep and marker and target == str(directory):
            return source, options.split(",", 1)[0].rstrip(")")
    return None


def readable(directory):
    try:
        return subprocess.run(["/bin/ls", "-a", str(directory)], stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL, timeout=5).returncode == 0
    except subprocess.TimeoutExpired:
        return False


def unmount(directory, mounted):
    try:
        result = subprocess.run(["/sbin/umount", str(directory)], capture_output=True, text=True, timeout=8)
        if result.returncode == 0:
            return True
    except subprocess.TimeoutExpired:
        pass
    current = mount_at(directory)
    if current is None:
        return True
    if current != mounted:
        raise RuntimeError(f"Mount at {directory} changed; left untouched.")
    if readable(directory):
        return False  # The mount recovered while we were trying to detach it.
    if mount_at(directory) != mounted:
        raise RuntimeError(f"Mount at {directory} changed; left untouched.")
    result = subprocess.run(["/usr/sbin/diskutil", "unmount", "force", str(directory)],
                            capture_output=True, text=True, timeout=12)
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip() or "unmount failed"
        raise RuntimeError(f"Forced unmount failed: {detail}")
    return True


def ensure_mount(directory, host, path):
    expected = (host, host + ":")
    mounted = mount_at(directory)
    if mounted:
        source, filesystem = mounted
        if source not in expected or filesystem not in SSHFS_TYPES:
            raise RuntimeError(f"Another filesystem is mounted at {directory}; left untouched.")
        if readable(directory):
            return
        if mount_at(directory) != mounted:
            raise RuntimeError(f"Mount at {directory} is unreadable; refusing to replace it.")
    executable = shutil.which("sshfs", path=path)
    if not executable:
        raise RuntimeError("Local sshfs executable not found.")
    if mounted and not unmount(directory, mounted):
        return
    if mount_at(directory) or directory.parent.is_symlink() or directory.is_symlink():
        raise RuntimeError(f"Unexpected mount or symlink at {directory}; left untouched.")
    directory.mkdir(parents=True, exist_ok=True)
    if any(directory.iterdir()):
        raise RuntimeError(f"Mount directory {directory} is not empty; left untouched.")
    start_mount(executable, directory, host)


def start_mount(executable, directory, host):
    command = [executable, "-f", "-o", "BatchMode=yes,reconnect,ConnectTimeout=5,"
               "ControlMaster=no,ControlPath=none,ServerAliveInterval=10,ServerAliveCountMax=2,volname=" + host,
               host + ":", str(directory)]
    # macFUSE can keep SSHFS in the foreground even without -f. The process
    # owns the mount, so wait for readability, not for the process to exit.
    with tempfile.TemporaryFile() as errors:
        process = subprocess.Popen(command, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                                   stderr=errors, start_new_session=True)
        ready = False
        try:
            deadline = time.monotonic() + 20
            while process.poll() is None and time.monotonic() < deadline:
                mounted = mount_at(directory)
                if (mounted and mounted[0] in (host, host + ":") and mounted[1] in SSHFS_TYPES
                        and readable(directory) and process.poll() is None):
                    ready = True
                    return
                time.sleep(0.2)
            end = errors.seek(0, os.SEEK_END)
            errors.seek(max(0, end - 2000))
            detail = errors.read(2000).decode(errors="replace").strip()
            raise RuntimeError(f"SSHFS did not provide a readable mount at {directory}."
                               + (f"\n{detail}" if detail else ""))
        finally:
            if not ready and process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()


def open_yazi(window, boss, directory, host, path, executable):
    from kitty.fast_data_types import add_timer, remove_timer

    pending = getattr(boss, "_sshfs_yazi_pending", None)
    if pending is None:
        pending = boss._sshfs_yazi_pending = set()
    if directory in pending:
        return
    pending.add(directory)
    result = Future()

    def check_mount():
        try:
            ensure_mount(directory, host, path)
        except Exception as exc:
            result.set_exception(exc)
        else:
            result.set_result(None)

    def finish(timer_id):
        if not result.done():
            return
        remove_timer(timer_id)
        pending.discard(directory)
        if boss.window_id_map.get(window.id) is not window:
            return
        try:
            result.result()
            boss.call_remote_control(window, (
                "launch", "--type=os-window", "--add-to-session=!", "--cwd=" + str(directory),
                executable, str(directory),
            ))
        except Exception as exc:
            detail = getattr(exc, "stderr", None) or str(exc)
            boss.show_error("Cannot open SSHFS in Yazi", detail.strip()[-2000:])

    threading.Thread(target=check_mount, daemon=True).start()
    add_timer(finish, 0.2, True)


def install_live(boss):
    from kitty.fast_data_types import get_options
    from kitty.options.utils import parse_map

    options = get_options()
    old, new = [
        next(iter(parse_map(mapping))).resolve_and_copy(options.kitty_mod)
        for mapping in ("cmd+shift+ctrl+t no_op", "cmd+shift+ctrl+y kitten helpers/sshfs_yazi.py")
    ]
    for keymap in (boss.mappings.keyboard_modes[""].keymap, options.keyboard_modes[""].keymap):
        previous = keymap.get(old.trigger, ())
        keep = [item for item in previous if not (
            item.definition.startswith("kitten ") and item.definition.endswith("/local_tab_kitten.py"))]
        if len(keep) != len(previous):
            if keep:
                keymap[old.trigger] = keep
            else:
                keymap.pop(old.trigger, None)
        keymap[new.trigger] = [item for item in keymap.get(new.trigger, ())
                              if item.options.when_focus_on] + [new]
    return "Installed Cmd+Shift+Ctrl+Y for SSHFS Yazi."


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    if args[1:] == ["--install-live"]:
        return install_live(boss)
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    values = window.user_vars
    host = values.get("kzw_host") or values.get("kzw_local_origin") or values.get("kzw_origin", "")
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", host):
        boss.show_error("Cannot open SSHFS in Yazi", "Select a workspace pane with an SSH host.")
        return
    home = Path.home()
    directory = home / "SSHFS" / host
    path = os.pathsep.join((os.environ.get("PATH", ""), str(home / ".cargo/bin"),
                           str(home / ".local/bin"), "/opt/homebrew/bin", "/usr/local/bin"))
    executable = shutil.which("yazi", path=path)
    if not executable:
        boss.show_error("Cannot open SSHFS in Yazi", "Local yazi executable not found.")
        return
    open_yazi(window, boss, directory, host, path, executable)
