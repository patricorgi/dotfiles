# Clickable Kitty session notifications

OpenCode V2 TUI-only plugin, tested with OpenCode 2.2.7, Kitty 0.50 and zmx 0.5.
It uses OpenCode's embedded JavaScript runtime: Node, Bun, npm, a daemon and an
extra network port are not required on the remote host.

## Install

Copy this directory to the machine running the **TUI**, then run:

```sh
python3 /path/to/opencode-kitty-notify/install.py
```

The installer respects `XDG_CONFIG_HOME`, backs up changed files, installs the
package into `opencode/plugins/kitty-session-notify`, and updates `cli.json`.
The built-in notification plugin is disabled to avoid duplicates. Existing
unrelated configuration is retained. CLI configuration/plugin reload does not
require restarting the OpenCode server or terminating sessions.
An automatically computed source revision in the plugin options makes upgrades
trigger a CLI plugin reload; reinstalling identical files is idempotent.

The local Kitty `notifications.py` in these dotfiles prefixes the originating
kzw workspace. Exact session titles and session IDs come from the TUI, not the
currently selected pane's title. Completion/failure alerts are emitted only for
top-level sessions open in this TUI, on their own execution-terminal events.
Subagent completion/failure events are silent: they are not relabelled as parent
completion. Parent executions started by automatic subagent reports are also
silent. The first delivered inbox input identifies the execution's origin;
later steering or child reports do not silence a user-started turn. After a
mid-execution plugin reload, recent input metadata is used as a fallback.
Questions and permission requests from owned child sessions still
produce actionable notifications. `attention.notifications`, `attention.sound`
and inline CLI overrides are read when notifications are generated.

Questions/forms use visible field titles and descriptions as their question
text, falling back to the form title if needed. Kitty displays them as
`[?] WORKSPACE - QUESTION BODY`; the notification body retains the exact session
name and ID, and clicks use the same session-switching path. Multiple questions
are separated by ` / `. Hidden/external fields, defaults and option values are
not forwarded. Ordinary completion notification formatting is unchanged.

## Click path

The plugin sends OSC 99 with `a=focus,report` and `o=unfocused`. Kitty focuses
the originating OS window/tab/pane and returns the opaque notification token
through the same terminal/SSH/zmx path. The originating TUI consumes the reply,
checks its instance-local mapping, verifies that the session still exists,
then focuses that session. Foreign, expired and malformed tokens in the plugin's
namespace are consumed without navigation. No terminal commands are injected.

`/kitty-notify-test` schedules a clearly labelled test for the current session;
`/kitty-notify-test SESSION_ID` tests an already-open background session. Move
focus to another pane/application within three seconds to see it, because
focused panes are muted. Pending test timers are cancelled on plugin cleanup.
Kitty's `opencode_notify` user variable reports the loaded plugin version,
source revision and instance nonce. It is diagnostic metadata, not authentication.

## Boundaries

- Requires an attached terminal path carrying OSC 99 in both directions.
- Does not notify while detached and does not recreate or reconnect sessions.
- Tokens are instance-local, single-use, bounded to 128 and expire after ten
  minutes. Normal plugin cleanup withdraws outstanding notifications.
- Hard crashes cannot run cleanup. Old notifications may remain until expiry;
  do not rely on click-back after the originating TUI has exited into a shell.
  A replacement compatible TUI consumes stale tokens without switching session.
- The renderer input parser assembles terminal sequences; plugin replies are
  handled before ordinary key/text delivery.
- The notification contains the session title and ID. Question notifications
  additionally expose question text on the local desktop/lock screen. Model
  prompts, answers, field defaults, permission arguments and credentials are
  not intentionally forwarded. Desktop/title length limits still apply.

To undo installation, restore the relevant `plugins` entries from the config
backup, preserving any later unrelated edits. Do not blindly overwrite a newer
configuration with the entire backup.

## Tests

From the dotfiles repository root:

```sh
node --test scripts/tests/test_opencode_kitty_notify.mjs
python3 scripts/tests/test_opencode_kitty_notify_install.py
kitty +runpy 'import runpy; runpy.run_path("scripts/tests/test_kitty_notifications.py", run_name="__main__")'
```
