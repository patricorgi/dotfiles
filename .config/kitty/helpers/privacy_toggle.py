"""Toggle visual privacy across every tab and pane in one Kitty OS window."""

from pathlib import Path

from kittens.tui.handler import result_handler
from kitty.constants import config_dir


MARKER = str(Path(config_dir) / "helpers/privacy_marker.py")


def is_private(window):
    spec = getattr(window, "current_marker_spec", None)
    return (isinstance(spec, (tuple, list)) and len(spec) == 2 and spec[0] == "function"
            and isinstance(spec[1], str) and spec[1].rsplit("/", 1)[-1] == "privacy_marker.py")


def toggle_privacy(manager):
    windows = [window for tab in manager.tabs for window in tab]
    # Mixed legacy pane states count as enabled: one press clears them all.
    enabled = not any(is_private(window) for window in windows)
    for window in windows:
        if enabled:
            window.set_marker(["function", MARKER])
        elif is_private(window):
            window.remove_marker()
    manager.update_tab_bar_data()
    manager.mark_tab_bar_dirty()
    return enabled


def install_live(boss, path):
    """Replace only the privacy shortcut, without reloading other settings."""
    from kitty.fast_data_types import get_options
    from kitty.options.utils import parse_map

    options = get_options()
    path = str(Path(path).expanduser().resolve())
    definition = next(iter(parse_map("kitty_mod+m kitten " + path))).resolve_and_copy(options.kitty_mod)
    boss.mappings.keyboard_modes[""].keymap[definition.trigger] = [definition]
    options.keyboard_modes[""].keymap[definition.trigger] = [definition]


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    if args[1:] == ["--install-live"]:
        install_live(boss, args[0])
        return
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    manager = boss.os_window_map.get(window.os_window_id)
    if manager is not None:
        return toggle_privacy(manager)
