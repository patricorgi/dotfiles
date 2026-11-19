"""Browse the last command, its start directory and output in a Neovim overlay."""

import re
from pathlib import Path
from urllib.parse import urlsplit

from kittens.tui.handler import result_handler
from kitty.notifications import OnlyWhen
from kitty.utils import kitty_ansi_sanitizer_pat, path_from_osc7_url


NVIM = [
    "nvim", "--clean", "--cmd", "set eventignore=FileType",
    "-c", "set clipboard=unnamedplus", "-c", "call nvim_open_term(0, {})",
    "-c", "set nomodified nolist", "-c", "normal! G", "-",
]
MARK = re.compile(r"\x1b\]133;([AC])(?:;[^\x07\x1b]*)?(?:\x07|\x1b\\)")
STATE = "_last_command_context"


def on_cmd_startstop(boss, window, data):
    if data["is_start"]:
        # This callback is synchronous: capture OSC 7 before `cd` can update it.
        cwd = window.screen.last_reported_cwd
        if isinstance(cwd, bytes):
            cwd = cwd.decode("utf-8", "replace")
        setattr(window, STATE, {
            "cwd": cwd,
            "cmdline": data.get("cmdline", ""),
        })


def literal(text):
    """Do not interpret control sequences embedded in command/path metadata."""
    return "".join(c if c in "\n\t" or (ord(c) >= 32 and not 127 <= ord(c) < 160)
                   else f"\\x{ord(c):02x}" for c in text)


def last_prompt(text):
    """Keep the displayed prompt/command verbatim, not a guessed shell command."""
    marks = list(MARK.finditer(text))
    output = next((m for m in reversed(marks) if m[1] == "C"), None)
    if output is None:
        return ""
    prompt = next((m for m in reversed(marks) if m[1] == "A" and m.start() < output.start()
                   and ";k=s" not in m[0]), None)
    if prompt is None:
        return ""
    return MARK.sub("", text[prompt.end():output.start()]).rstrip("\r\n")


def command_without_output(text, at_prompt):
    # A zero-output command can have its C marker overwritten by the next A.
    # Never pair that command with an older command's non-empty output.
    if not at_prompt:
        return ""
    prompts = [m for m in MARK.finditer(text) if m[1] == "A" and ";k=s" not in m[0]]
    if len(prompts) < 2:
        return ""
    block = text[prompts[-2].end():prompts[-1].start()]
    if any(m[1] == "C" for m in MARK.finditer(block)):
        return ""
    return MARK.sub("", block).rstrip("\r\n")


def transcript(window):
    context = getattr(window, STATE, {})
    cmdline = window.last_cmd_cmdline
    if context.get("cmdline") != cmdline:
        context = {}
    history = window.as_text(as_ansi=True, add_history=True)
    empty_prompt = command_without_output(history, getattr(window, "at_prompt", False))
    if empty_prompt:
        # Without a retained output-start mark, metadata may refer to an older command.
        context, cmdline = {}, ""
    uri = context.get("cwd", "")
    directory = path_from_osc7_url(uri) if uri else ""
    if directory:
        host = urlsplit(uri).hostname or ""
        directory = f"{host}:{directory}" if host else directory
    else:
        directory = "[unavailable: command start directory was not reported/recorded]"
    header = f"Directory: {literal(directory)}\r\n"
    if cmdline:
        header += f"$ {literal(cmdline)}\r\n"
    else:
        prompt = empty_prompt or last_prompt(history)
        header += (f"Prompt / command:\r\n{prompt}\r\n" if prompt else
                   "Command: [unavailable: shell integration did not report it]\r\n")
    # Same ANSI-preserving output source as @last_cmd_output; never rerun a command.
    return header + "\x1b[0m\r\n" + ("" if empty_prompt else window.cmd_output(as_ansi=True))


def install_live(boss, path):
    """Update these bindings/watcher only; do not rebuild Cocoa's native shortcuts."""
    from kitty.fast_data_types import get_options
    from kitty.launch import load_watch_modules
    from kitty.options.utils import parse_map

    path = str(Path(path).expanduser().resolve())
    get_options().watcher[path] = path
    watchers = load_watch_modules((path,))
    for window in boss.all_windows:
        if watchers:
            window.watchers.add(watchers)
    for binding in ("cmd+ctrl+shift+f kitten " + path,
                    "cmd+ctrl+shift+c kitten " + path + " --copy"):
        definition = next(iter(parse_map(binding)))
        boss.mappings.keyboard_modes[""].keymap[definition.trigger] = [definition]
        get_options().keyboard_modes[""].keymap[definition.trigger] = [definition]


def plain_transcript(window):
    text = transcript(window)
    # OSC 66 wraps visible text; unwrap it before removing formatting/hyperlinks.
    text = re.sub(r"\x1b\]66;[^;\x1b\x07]*;([^\x1b\x07]*)(?:\x07|\x1b\\)", r"\1", text)
    return kitty_ansi_sanitizer_pat().sub("", text).replace("\r", "")


def notify_copy(boss, window):
    manager = boss.notification_manager
    notification = manager.create_notification_cmd()
    notification.title = "已复制"
    notification.body = "执行路径、命令和输出已复制到剪贴板。"
    notification.application_name = "kitty"
    notification.only_when = OnlyWhen.always
    notification.actions = frozenset()
    notification.identifier = f"last-command-copy-{window.id}"
    notification.timeout = 3000
    manager.notify_with_command(notification, window.id)


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
    if args[1:] == ["--copy"]:
        boss.clipboard.set_text(plain_transcript(window))
        notify_copy(boss, window)
        return
    if (tab := window.tabref()) is None:
        return
    tab.new_window(cmd=NVIM, stdin=transcript(window).encode("utf-8"),
                   overlay_for=window.id, copy_colors_from=window)
