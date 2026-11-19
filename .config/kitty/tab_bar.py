"""Draw rounded active tabs and cached kzw host usage at the right edge."""

import re
import time
from functools import wraps
from typing import NamedTuple

from kitty.fast_data_types import add_timer, get_boss, get_options, mark_tab_bar_dirty
from kitty.fast_data_types import set_tab_bar_render_data, viewport_for_window, wcswidth
from kitty.tab_bar import TabBar, as_rgb, draw_tab_with_separator
from kitty.window import Window

WORKSPACE_ICON = '\uebeb'   # Nerd Fonts cod-layout
HOST_ICON = '\U000f08b9'    # User-selected host glyph
CPU_ICON = '\U000f0ee0'     # Nerd Fonts md-cpu_64_bit
MEMORY_ICON = '\uefc5'      # Nerd Fonts fa-memory
WORKSPACE_COLOR = 0xcba6f7  # Mocha mauve
HOST_COLOR = 0x89b4fa       # Mocha blue
SEPARATOR_COLOR = 0x9399b2  # Mocha Overlay 2, matching light tab indices
USAGE_COLORS = (0xa6e3a1, 0xf9e2af, 0xf38ba8)  # Mocha green, yellow, red
LOCAL_COLOR = 0x89b4fa  # Mocha blue, independent of active workspace colors


def local_tab(tab):
    kitty_tab = get_boss().tab_for_id(tab.tab_id)
    if kitty_tab is None:
        return False
    windows = list(kitty_tab)
    if len(windows) != 1:
        return False
    values = windows[0].user_vars
    return (re.fullmatch(r'kzw-[0-9a-f]{32}', values.get('kzw_local', '')) is not None and
            re.fullmatch(r'[0-9a-f]{32}', values.get('kzw_local_owner', '')) is not None and
            not values.get('kzw_pane') and not values.get('kzw_workspace'))


def privacy_enabled(os_window_id):
    manager = get_boss().os_window_map.get(os_window_id)
    if manager is None:
        return False
    for kitty_tab in manager.tabs:
        for window in kitty_tab:
            spec = getattr(window, 'current_marker_spec', None)
            if (isinstance(spec, (tuple, list)) and len(spec) == 2 and spec[0] == 'function'
                    and isinstance(spec[1], str) and spec[1].rsplit('/', 1)[-1] == 'privacy_marker.py'):
                return True
    return False


def mask_identity(text, os_window_id):
    manager = get_boss().os_window_map.get(os_window_id)
    record = getattr(manager, '_kzw_resource_usage', None)
    if record and privacy_enabled(os_window_id):
        names = {record.get(key) for key in ('host', 'workspace')} - {None, ''}
        for name in sorted(names, key=len, reverse=True):
            text = text.replace(name, '•' * wcswidth(name))
    return text


def zoom_title_span(tab):
    if getattr(tab, 'layout_name', '') != 'stack' or getattr(tab, 'num_window_groups', 0) < 2:
        return None
    kitty_tab = get_boss().tab_for_id(tab.tab_id)
    if kitty_tab is None or kitty_tab.active_window is None:
        return None
    active = kitty_tab.active_window
    if not kitty_tab.name and tab.title == active.title:
        return 0, len(tab.title)
    windows = list(kitty_tab)
    panes = [window.user_vars.get('kzw_pane', '') for window in windows]
    if (not all(isinstance(pane, str) and re.fullmatch(r'kzw-[0-9a-f]{32}', pane) for pane in panes)
            or len(set(panes)) != len(windows)):
        return None
    selected = next((i for i, window in enumerate(windows) if window.id == active.id), None)
    if selected is None:
        return None
    labels = tab.title.split(' · ')
    if len(labels) != len(windows):
        state = active.user_vars.get('kzw_command_state', '')
        status = ('running' if state == 'running' else 'exit ' + state[5:]
                  if isinstance(state, str) and re.fullmatch(r'exit:-?[0-9]{1,10}', state) else None)
        if len(labels) != len(windows) + 1 or status is None or labels[selected + 1] != status:
            return None
    start = sum(len(label) + 3 for label in labels[:selected])
    return start, start + len(labels[selected])


def draw_title(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    title = mask_identity(tab.title, tab.os_window_id)
    span = zoom_title_span(tab)
    if span is not None:
        start, end = span
        color = '0;0;0' if tab.is_active else '255;255;255'
        foreground = draw_data.tab_fg(tab)
        normal = ';'.join(str((foreground >> shift) & 255) for shift in (16, 8, 0))
        weight = '1' if screen.cursor.bold else '22'
        prefix, name, suffix = (mask_identity(part, tab.os_window_id) for part in
                                (tab.title[:start], tab.title[start:end], tab.title[end:]))
        title = prefix + f'\x1b[1;38;2;{color}m' + name + f'\x1b[{weight};38;2;{normal}m' + suffix
    if title != tab.title:
        tab = tab._replace(title=title)
    if not tab.is_active or max_tab_length < 4:
        return draw_tab_with_separator(
            draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data)

    template = draw_data.active_title_template or draw_data.title_template
    padded = draw_data._replace(
        active_title_template=template.strip(),
        leading_spaces=1, trailing_spaces=1)
    return draw_tab_with_separator(
        padded, screen, tab, before, max_tab_length, index, is_last, extra_data)


def usage_color(value):
    position = max(0, min(100, value)) / 50
    low, high = USAGE_COLORS[:2] if position <= 1 else USAGE_COLORS[1:]
    fraction = position if position <= 1 else position - 1
    return sum(round(((low >> shift) & 255) * (1 - fraction) +
                     ((high >> shift) & 255) * fraction) << shift for shift in (16, 8, 0))


def resource_segments(tab, neutral):
    manager = get_boss().os_window_map.get(tab.os_window_id)
    record = getattr(manager, '_kzw_resource_usage', None)
    if not record or manager.active_tab is None:
        return []
    window = manager.active_tab.active_window
    if window is None:
        return []
    values = window.user_vars
    local = bool(values.get('kzw_local'))
    if (values.get('kzw_local_workspace' if local else 'kzw_workspace') != record['workspace'] or
            values.get('kzw_local_origin' if local else 'kzw_origin', '') != record['origin']):
        return []
    fresh = time.monotonic() < record['expires']
    segments = [(f"{WORKSPACE_ICON} {mask_identity(record['workspace'], tab.os_window_id)}", WORKSPACE_COLOR),
                (' · ', SEPARATOR_COLOR),
                (f"{HOST_ICON} {mask_identity(record['host'], tab.os_window_id)}", HOST_COLOR)]
    detach = getattr(manager, '_kzw_detach_in_progress', None)
    if (isinstance(detach, dict) and detach.get('workspace') == record['workspace'] and
            detach.get('origin') == record['origin']):
        return segments + [(' · ', SEPARATOR_COLOR), ('Detaching…', 0xf9e2af), (' ', neutral)]
    states = {values.get('kzw_connection', '') for kitty_tab in manager.tabs for window in kitty_tab
              for values in (getattr(window, 'user_vars', {}),)
              if values.get('kzw_workspace') == record['workspace'] and values.get('kzw_origin', '') == record['origin']}
    state = record.get('connection', '')
    if 'connection' in record and time.monotonic() >= record.get('connection_expires', 0):
        state = 'stalled'
    states.add(state)
    labels = (('offline', 'Waiting for network…'),
              ('stalled', 'Connection stalled…'), ('reconnecting', 'Reconnecting…'),
              ('restoring', 'Restoring…'), ('connecting', 'Connecting…'))
    label = next((label for state, label in labels if state in states), None)
    if label is not None:
        return segments + [(' · ', SEPARATOR_COLOR), (label, 0xf9e2af), (' ', neutral)]
    for icon, key in ((CPU_ICON, 'cpu'), (MEMORY_ICON, 'ram')):
        segments.append((' · ', SEPARATOR_COLOR))
        value = record[key] if fresh else None
        text = f'{value:.0f}%' if value is not None else '—'
        segments.append((f'{icon} {text}', usage_color(value) if value is not None else neutral))
    segments.append((' ', neutral))
    return segments


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    manager = get_boss().os_window_map.get(tab.os_window_id)
    indices = getattr(getattr(manager, 'tab_bar', None), '_kzw_tab_indices', {})
    index = indices.get(tab.tab_id, index)
    if local_tab(tab):
        cursor = screen.cursor
        title = mask_identity(tab.title, tab.os_window_id)
        title = ''.join(c for c in title if c.isprintable())[:100]
        if not title or title in ('Local', 'kzw', 'kzw.local_tabs'):
            title = '?'
        label = ' ' + title + ' '
        width = min(wcswidth(label), max(1, max_tab_length))
        if not extra_data.for_layout and draw_data.tab_bar_edge in ('top', 'bottom'):
            segments = resource_segments(tab, int(draw_data.inactive_fg))
            reserved = sum(wcswidth(text) for text, _ in segments) + 2 if segments else 0
            if screen.columns - reserved - width < before + 2:
                reserved = 0  # Hide status rather than overwrite a real tab.
            start = max(before, screen.columns - reserved - width)
            cursor.bg = as_rgb(int(draw_data.default_bg))
            cursor.bold = cursor.italic = False
            screen.draw(' ' * (start - cursor.x))
            if manager is not None:
                manager.tab_bar._kzw_local_start = (tab.tab_id, start)
        cursor.fg = as_rgb(LOCAL_COLOR)
        cursor.bg = as_rgb(0x313244 if tab.is_active else int(draw_data.default_bg))
        cursor.bold, cursor.italic = tab.is_active, False
        if width < wcswidth(label):
            truncated = ''
            for char in label:
                if wcswidth(truncated + char) > width - 1:
                    break
                truncated += char
            label = truncated + '…'
        screen.draw(label)
        end = cursor.x
    else:
        end = draw_title(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data)
    if is_last and not extra_data.for_layout and draw_data.tab_bar_edge in ('top', 'bottom'):
        neutral = int(draw_data.inactive_fg)
        segments = resource_segments(tab, neutral)
        start = screen.columns - sum(wcswidth(text) for text, _ in segments)
        if segments and start >= screen.cursor.x + 2:
            cursor = screen.cursor
            fg, bg, bold, italic = cursor.fg, cursor.bg, cursor.bold, cursor.italic
            cursor.fg = as_rgb(neutral)
            cursor.bg = as_rgb(int(draw_data.default_bg))
            cursor.bold = cursor.italic = False
            screen.draw(' ' * (start - cursor.x))
            for text, color in segments:
                cursor.fg = as_rgb(color)
                screen.draw(text)
            cursor.fg, cursor.bg, cursor.bold, cursor.italic = fg, bg, bold, italic
            # Keep the actual tab's click extent; the status is not another tab.
    return end


# Kitty normally splits the unused fraction of a character cell between both
# edges. Leave those spare pixels on the right so the configured left margin
# remains equal to the top margin at every window width.
native_layout = getattr(TabBar.layout, '_native_layout', TabBar.layout)
draw_tab._equal_margins = True
draw_tab._kzw_resources = True
draw_tab._kzw_privacy = True
draw_tab._kzw_connection = True
draw_tab._kzw_connecting = True
draw_tab._kzw_network_pause = True
draw_tab._kzw_detaching = True
draw_tab._kzw_local_tabs = True
draw_tab._kzw_local_program = True


def redraw_after_marker_change(native):
    @wraps(native)
    def changed(window, *args, **kwargs):
        try:
            return native(window, *args, **kwargs)
        finally:
            manager = get_boss().os_window_map.get(window.os_window_id)
            if manager is not None and getattr(manager.tab_bar.draw_func, '_kzw_privacy', False):
                manager.update_tab_bar_data()
                manager.mark_tab_bar_dirty()

    changed._privacy_native = native
    return changed


for marker_action in ('toggle_marker', 'set_marker', 'remove_marker'):
    action = getattr(Window, marker_action)
    setattr(Window, marker_action, redraw_after_marker_change(getattr(action, '_privacy_native', action)))


def layout(self):
    native_layout(self)
    if not getattr(self.draw_func, '_equal_margins', False) or self.is_vertical or not self.laid_out_once:
        return
    geometry = self.window_geometry
    offset = geometry.left - self.margin_width
    if offset <= 0:
        return
    geometry = geometry._replace(left=geometry.left - offset, right=geometry.right - offset)
    self.window_geometry = geometry
    self.update_blank_rects(*self._last_viewport)
    set_tab_bar_render_data(self.os_window_id, self.screen, *geometry[:4])


layout._native_layout = native_layout
TabBar.layout = layout


SLIDE_SECONDS = 0.180
# The shader reads four blank cells at one of these distances from the right.
# The alternatives leave room for kzw's right-aligned host stats.
SLIDE_SLOTS = (0, 32, 48, 64)
SLIDE_SIGNATURE = (1, 2, 3, 2)


class TabSlide(NamedTuple):
    layout: tuple
    tab_id: int
    source: tuple
    target: tuple
    started: float

    def bounds(self, now):
        remaining = 1 - min(1.0, max(0.0, (now - self.started) / SLIDE_SECONDS))
        return tuple(round(end + (start - end) * remaining ** 3)
                     for start, end in zip(self.source, self.target))


def slide_marker_color(value, signature):
    packed = value | (signature << 13)
    # Widely spaced sRGB levels survive Kitty's linear-color framebuffer.
    channels = [96 + 5 * ((packed >> shift) & 31) for shift in (10, 5, 0)]
    return as_rgb((channels[0] << 16) | (channels[1] << 8) | channels[2])


native_update_horizontal = getattr(TabBar.update_horizontal, '_native_update_horizontal',
                                   TabBar.update_horizontal)
draw_tab._slide_lite = True


def update_horizontal(self, data):
    alignment = None
    if getattr(self.draw_func, '_kzw_local_tabs', False):
        self._kzw_tab_indices = {tab.tab_id: i for i, tab in enumerate(data, 1)}
        self._kzw_local_start = None
        data = [tab for tab in data if not local_tab(tab)] + [tab for tab in data if local_tab(tab)]
        if any(local_tab(tab) for tab in data):
            alignment = self.align
            self.align = lambda: None  # Local defines a left/right layout, not one centered cluster.
    try:
        changed = native_update_horizontal(self, data)
    finally:
        if alignment is not None:
            self.align = alignment
    if getattr(self, '_kzw_local_start', None) is not None:
        tab_id, start = self._kzw_local_start
        self.tab_extents = [item._replace(x=item.x._replace(start=start)) if item.tab_id == tab_id else item
                            for item in self.tab_extents]
    if any(tab.is_active and local_tab(tab) for tab in data):
        self._tab_slide = None  # Do not animate the workspace highlight onto Local.
        return changed
    if not getattr(self.draw_func, '_slide_lite', False) or \
            'active-tab-slide-lite' not in get_options().custom_shaders:
        return changed

    active = next((tab for tab in data if tab.is_active), None)
    extent = next((item.x for item in self.tab_extents
                   if active is not None and item.tab_id == active.tab_id), None)
    if extent is None:
        self._tab_slide = None
        return changed

    screen = self.screen
    g = self.window_geometry
    _, _, viewport_width, _, cell_width, cell_height = viewport_for_window(self.os_window_id)
    # Match the Retina geometry decoded in the shader. Fall back to the
    # normal instantaneous highlight if this grid cannot be encoded safely.
    if (g.left, g.top) != (12, 12) or cell_width != (24 * cell_height + 52) // 53 or \
            screen.columns != (viewport_width - 24) // cell_width:
        self._tab_slide = None
        return changed
    target = (g.left + extent.start * cell_width, g.left + extent.end * cell_width)
    layout_key = (viewport_width, cell_width, cell_height)
    now = time.monotonic()
    old = getattr(self, '_tab_slide', None)
    if old is None or old.layout != layout_key:
        slide = TabSlide(layout_key, active.tab_id, target, target, now)
    elif old.tab_id != active.tab_id:
        slide = TabSlide(layout_key, active.tab_id, old.bounds(now), target, now)
    else:
        slide = old._replace(target=target)

    self._tab_slide = slide
    if slide.source == slide.target or now - slide.started >= SLIDE_SECONDS:
        self._tab_slide = slide._replace(source=target)
        return changed

    line = screen.line(0)
    after_tabs = max(item.x.end for item in self.tab_extents)
    slot = next((start for offset in SLIDE_SLOTS
                 if (start := screen.columns - 4 - offset) > after_tabs
                 and all(line[x] in (' ', '\x00') for x in range(start, start + 4))), None)
    values = (*slide.bounds(now), *target)
    if slot is None or any(value < 0 or value >= 8192 for value in values):
        self._tab_slide = slide._replace(source=target)
        return changed

    cursor = screen.cursor
    previous_x, previous_bg = cursor.x, cursor.bg
    cursor.x = slot
    for value, signature in zip(values, SLIDE_SIGNATURE):
        cursor.bg = slide_marker_color(value, signature)
        screen.draw(' ')
    cursor.x, cursor.bg = previous_x, previous_bg

    if not getattr(self, '_tab_slide_timer', None):
        def next_frame(_timer_id):
            self._tab_slide_timer = None
            manager = get_boss().os_window_map.get(self.os_window_id)
            if manager is not None and not manager.tab_bar_hidden and manager.tab_bar_should_be_visible:
                manager.update_tab_bar_data()
                mark_tab_bar_dirty(self.os_window_id, True)

        self._tab_slide_timer = add_timer(next_frame, 0.010, False)
    return changed


update_horizontal._native_update_horizontal = native_update_horizontal
TabBar.update_horizontal = update_horizontal
