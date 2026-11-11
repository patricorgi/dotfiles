"""Draw rounded active tabs and cached kzw host usage at the right edge."""

import time
from typing import NamedTuple

from kitty.fast_data_types import add_timer, get_boss, get_options, mark_tab_bar_dirty
from kitty.fast_data_types import set_tab_bar_render_data, viewport_for_window, wcswidth
from kitty.tab_bar import TabBar, as_rgb, draw_tab_with_separator

LEFT_CORNER = '\ue100'
RIGHT_CORNER = '\ue101'
CPU_ICON = '\U000f061a'     # Nerd Fonts md-chip
MEMORY_ICON = '\uefc5'      # Nerd Fonts fa-memory
USAGE_COLORS = (0xa6e3a1, 0xf9e2af, 0xf38ba8)  # Mocha green, yellow, red


def draw_title(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    if not tab.is_active or max_tab_length < 4:
        return draw_tab_with_separator(
            draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data)

    template = draw_data.active_title_template or draw_data.title_template
    number = '{fmt.fg._585b70}{index}{fmt.fg.tab}'  # Mocha Surface 2
    padded = draw_data._replace(
        active_title_template=template.strip().replace('{index}', number, 1),
        leading_spaces=1, trailing_spaces=1)
    start = screen.cursor.x
    end = draw_tab_with_separator(
        padded, screen, tab, before, max_tab_length, index, is_last, extra_data)
    if end - start < 3 or extra_data.for_layout:
        return end

    cursor = screen.cursor
    x, fg, bg = cursor.x, cursor.fg, cursor.bg
    cursor.fg = as_rgb(draw_data.tab_bg(tab))
    cursor.bg = as_rgb(int(draw_data.default_bg))
    cursor.x = start
    screen.draw(LEFT_CORNER)
    cursor.x = end - 1
    screen.draw(RIGHT_CORNER)
    cursor.x, cursor.fg, cursor.bg = x, fg, bg
    return end


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
    if window is None or window.user_vars.get('kzw_workspace') != record['workspace'] or \
            window.user_vars.get('kzw_origin', '') != record['origin']:
        return []
    fresh = time.monotonic() < record['expires']
    segments = [(f"{record['host']} · ", neutral)]
    for index, (icon, key) in enumerate(((CPU_ICON, 'cpu'), (MEMORY_ICON, 'ram'))):
        value = record[key] if fresh else None
        text = f'{value:.0f}%' if value is not None else '—'
        segments.append((f'{icon} {text}', usage_color(value) if value is not None else neutral))
        segments.append((' · ' if index == 0 else ' ', neutral))
    return segments


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
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
    changed = native_update_horizontal(self, data)
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
