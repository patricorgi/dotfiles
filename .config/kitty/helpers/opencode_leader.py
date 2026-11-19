"""Bypass the IME for one key after OpenCode's Ctrl+X leader."""

import os
import re

from kittens.tui.handler import result_handler
from kitty.fast_data_types import get_boss


MODE = "opencode_ascii_leader"
OWNER = "_opencode_ascii_leader_owner"
WATCHERS = "_opencode_ascii_leader_watchers"


def main(args):
    pass


def is_opencode(window):
    if window.at_prompt:
        return False
    if any(report.get("app", "").lower() == "opencode" for report in window.program_status.as_list()):
        return True
    # Covers SSH clients that forward titles but not program-status reports.
    title = window.child_title or window.title
    return bool(re.match(r"^(?:OC\s*\||opencode(?:\s|:|\||$))", title, re.IGNORECASE))


def cancel_for_window(window_id, boss=None):
    boss = boss if boss is not None else get_boss()
    if boss is not None and getattr(boss, OWNER, None) == window_id:
        boss.mappings.pop_keyboard_mode_if_is(MODE)
        delattr(boss, OWNER)


def on_focus_change(boss, window, data):
    if not data["focused"]:
        cancel_for_window(window.id, boss)


def on_close(boss, window, data):
    cancel_for_window(window.id, boss)


def remove_legacy_callbacks(window):
    """Remove only this helper's callbacks; preserve unrelated kitten lifecycle hooks."""
    source = os.path.realpath(on_close.__code__.co_filename)
    removed = 0
    for attribute, name in (("actions_on_focus_change", "on_focus_change"),
                            ("actions_on_close", "on_close")):
        callbacks = getattr(window, attribute)
        def owned(callback):
            code = getattr(callback, "__code__", None)
            namespace = getattr(callback, "__globals__", {})
            return (getattr(callback, "__name__", "") == name and code is not None and
                    os.path.realpath(code.co_filename) == source and
                    namespace.get("MODE") == MODE and namespace.get("OWNER") == OWNER)
        kept = [callback for callback in callbacks if not owned(callback)]
        removed += len(callbacks) - len(kept)
        callbacks[:] = kept
    return removed


def ensure_watchers(window):
    # Kitty excludes windows with actions_on_* callbacks from session exports.
    # Watchers provide the same notifications without making a real pane transient.
    callbacks = getattr(window, WATCHERS, None)
    if callbacks is None:
        callbacks = (on_focus_change, on_close)
        setattr(window, WATCHERS, callbacks)
    for target, callback in ((window.watchers.on_focus_change, callbacks[0]),
                             (window.watchers.on_close, callbacks[1])):
        if callback not in target:
            target.append(callback)


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    if args[1:] == ["--repair-live"]:
        repaired = 0
        for window in boss.window_id_map.values():
            if remove_legacy_callbacks(window):
                ensure_watchers(window)
                repaired += 1
        return f"Repaired {repaired} windows"
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    # Forward the original leader exactly once, including outside OpenCode.
    window.send_key("ctrl+x")
    if not is_opencode(window):
        return
    remove_legacy_callbacks(window)
    ensure_watchers(window)
    setattr(boss, OWNER, window.id)
    boss.push_keyboard_mode(MODE)
