"""Label OpenCode alerts with their workspace and suppress focused-pane alerts."""

import re

from kitty.notifications import Channel, NotificationCommand


def main(notification: NotificationCommand) -> bool:
    channel = Channel()
    window = channel.window_for_id(notification.channel_id)
    pane_title = window.title.removeprefix("OC | ").strip() if window else ""
    precise_session = notification.application_name.casefold() == "opencode" and re.fullmatch(
        r"ocn-[0-9a-f]{32}-[0-9a-f]{32}", notification.identifier
    )
    generic_title = not precise_session and re.match(r"opencode\b", notification.title, re.IGNORECASE)
    if notification.application_name.casefold() != "opencode":
        # OpenTUI can send the session title without application metadata.
        opencode_pane = window and window.title.startswith("OC | ")
        session_alert = opencode_pane and notification.identifier.startswith("opentui-")
        if notification.application_name or not (generic_title or session_alert):
            return False
    if channel.ui_state(notification.channel_id).has_keyboard_focus:
        return True

    workspace = window.user_vars.get("kzw_workspace", "") if window else ""
    if precise_session and "opencode.question" in notification.notification_types:
        notification.title = f"[?] {workspace or 'unknown'} - {notification.title}"
        return False
    prefix = f"[{workspace}] " if workspace else ""
    if not generic_title:
        # Keep the event's session title, not the currently selected session.
        notification.title = prefix + notification.title
    elif window and window.title.startswith("OC | ") and pane_title:
        # Generic alerts do not identify which internal OpenCode tab completed.
        notification.title = prefix + "Pane: " + pane_title
    else:
        notification.title = prefix + notification.title
    return False
