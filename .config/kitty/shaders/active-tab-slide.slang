#language slang 2026

import kitty_custom_shader_types;

static const int PASS = 0;
static const float SLIDE_MS = 180.0;
// The tab bar has 6 pt top/left margins and a 3 pt inner margin on Retina.
static const float TOP_GAP_PX = 12.0;
static const float LEFT_GAP_PX = 12.0;
static const float GAP_PX = 6.0;
static const float3 MAUVE = float3(0.597202, 0.381326, 0.930111);

float3 linear_rgb(float3 srgb) {
    return pow((srgb / 255.0 + 0.055) / 1.055, float3(2.4));
}

// Two 8-bit channels retain a pixel coordinate even on 8-bit framebuffers.
// Alpha stays opaque because Kitty premultiplies shader output.
float4 pack_value(float value) {
    uint n = uint(round(clamp(value, 0.0, 65535.0)));
    return float4(float(n >> 8) / 255.0, float(n & 255u) / 255.0, 0.0, 1.0);
}

float4 read_pixel(KittyTexture texture, float2 pixel, int column) {
    return texture.Sample(float2(float(column) + 0.5, 0.5) * pixel);
}

float read_value(KittyTexture texture, float2 pixel, int column) {
    float2 bytes = round(read_pixel(texture, pixel, column).rg * 255.0);
    return bytes.x * 256.0 + bytes.y;
}

float2 read_pair(KittyTexture texture, float2 pixel, int column) {
    return float2(read_value(texture, pixel, column), read_value(texture, pixel, column + 1));
}

bool is_mauve(KittyTexture texture, float y, float pixel_width, int x) {
    float3 rgb = texture.Sample(float2((float(x) + 0.5) * pixel_width, y)).rgb;
    return distance(rgb, MAUVE) < 0.035;
}

float2 selected_bounds(KittyTextures t, float2 pixel, int width, float2 row, float cell_width) {
    if (row.x >= row.y) return float2(0.0);
    float y = (row.x + row.y) * 0.5;
    int first = width;
    int last = -1;
    for (int x = 0; x < width; x += 8) {
        if (is_mauve(t.backbuffer, y, pixel.x, x)) {
            first = min(first, x);
            last = x;
        }
    }
    if (last < first) return float2(0.0);
    for (int x = max(0, first - 7); x < first; ++x) {
        if (is_mauve(t.backbuffer, y, pixel.x, x)) {
            first = x;
            break;
        }
    }
    for (int x = min(width - 1, last + 7); x > last; --x) {
        if (is_mauve(t.backbuffer, y, pixel.x, x)) {
            last = x;
            break;
        }
    }
    float2 measured = float2(float(first), float(last + 1));
    float2 aligned = LEFT_GAP_PX + round((measured - LEFT_GAP_PX) / cell_width) * cell_width;
    // Keep antialiased cap pixels with the highlight when they extend just
    // beyond the row of fully mauve pixels used to find it.
    if (all(abs(aligned - measured) <= 2.0)) return aligned;
    return measured;
}

float slide_progress(float now, float started) {
    float elapsed = now - started;
    if (elapsed < 0.0) elapsed += 60000.0;
    float remaining = 1.0 - saturate(elapsed / SLIDE_MS);
    return 1.0 - remaining * remaining * remaining;
}

float4 update_record(KittyTextures t, float2 pixel, int width, float2 row,
                     float row_height, float cell_width, float now, int column) {
    float2 target = selected_bounds(t, pixel, width, row, cell_width);
    float2 origin = read_pair(t.persist, pixel, 0);
    float2 previous = read_pair(t.persist, pixel, 2);
    float2 meta = read_pair(t.persist, pixel, 4);
    float started = meta.x;
    float previous_height = read_value(t.persist, pixel, 6);
    if (meta.y != float(width) || previous_height != row_height
        || previous.y <= previous.x || target.y <= target.x) {
        origin = target;
        started = now;
    } else if (any(previous != target)) {
        // Retarget rapid switches from the position that was already visible.
        origin = round(lerp(origin, previous, slide_progress(now, started)));
        started = now;
    } else if (slide_progress(now, started) >= 1.0) {
        origin = target;
    }
    if (column < 2) return pack_value(origin[column]);
    if (column < 4) return pack_value(target[column - 2]);
    if (column == 4) return pack_value(started);
    return pack_value(column == 5 ? float(width) : row_height);
}

float coverage_of(float3 color, float3 background, float3 ink) {
    float3 delta = ink - background;
    return saturate(dot(color - background, delta) / max(dot(delta, delta), 0.00001));
}

// The left glyph's advance can be fractional while Kitty's cell width is
// rounded up. Extend its last fully rendered part into the join with the body.
float left_cap_fill(KittyTexture texture, float2 pixel, float y, float left, float offset,
                    float cell_width, float3 background) {
    float3 cap = texture.Sample(float2((left + offset) * pixel.x, y)).rgb;
    float fill = coverage_of(cap, background, MAUVE);
    if (offset < cell_width - 2.0) return fill;
    float3 inner_cap = texture.Sample(float2((left + cell_width - 2.5) * pixel.x, y)).rgb;
    return max(fill, coverage_of(inner_cap, background, MAUVE));
}

float4 repair_settled_join(float4 color, KittyTextures t, KittyCustomShaderData d,
                           float2 pixel, float2 row, float cell_width, float now) {
    if (t.pos.y < row.x || t.pos.y >= row.y || cell_width < 4.0) return color;
    float2 target = read_pair(t.a, pixel, 2);
    float offset = t.pos.x / pixel.x - target.x;
    if (target.y <= target.x || offset < cell_width - 2.0 || offset >= cell_width) return color;
    float2 meta = read_pair(t.a, pixel, 4);
    if (meta.y != float(d.viewport_size_pixels.x)) return color;
    float2 origin = read_pair(t.a, pixel, 0);
    if (any(origin != target) && slide_progress(now, meta.x) < 1.0) return color;
    float3 background = d.background.rgb;
    float fill = left_cap_fill(t.backbuffer, pixel, t.pos.y, target.x, offset, cell_width, background);
    return float4(lerp(background, MAUVE, fill), color.a);
}

float4 paint_slide(float4 color, KittyTextures t, KittyCustomShaderData d,
                   float2 pixel, float2 row, float cell_width, float now) {
    if (t.pos.y < row.x || t.pos.y >= row.y) return color;
    float2 origin = read_pair(t.a, pixel, 0);
    float2 target = read_pair(t.a, pixel, 2);
    float2 meta = read_pair(t.a, pixel, 4);
    if (meta.y != float(d.viewport_size_pixels.x) || target.y - target.x < 2.0 * cell_width
        || all(origin == target)) return color;
    float progress = slide_progress(now, meta.x);
    if (progress >= 1.0) return color;

    float x = t.pos.x / pixel.x;
    float2 visible = lerp(origin, target, progress);
    bool under_target = x >= target.x && x < target.y;
    bool under_slide = x >= visible.x && x < visible.y;
    if (!under_target && !under_slide) return color;

    // Carry the current cap pixels with the moving pill, including their antialiasing.
    float3 background = d.background.rgb;
    float fill = 0.0;
    if (under_slide) {
        float left_offset = x - visible.x;
        float right_offset = visible.y - x;
        if (left_offset < cell_width) {
            fill = left_cap_fill(t.backbuffer, pixel, t.pos.y, target.x, left_offset,
                                 cell_width, background);
        } else if (right_offset <= cell_width) {
            float3 cap = t.backbuffer.Sample(float2((target.y - right_offset) * pixel.x, t.pos.y)).rgb;
            fill = coverage_of(cap, background, MAUVE);
        } else {
            fill = 1.0;
        }
    }
    float3 new_background = lerp(background, MAUVE, fill);
    if (under_target && (x < target.x + cell_width || x >= target.y - cell_width))
        return float4(new_background, color.a);

    // Recover text coverage from the two Mocha ink colors and composite it
    // in place over the moving fill. The labels never translate.
    float3 inactive_title = linear_rgb(float3(205, 214, 244));
    float3 inactive_number = linear_rgb(float3(147, 153, 178));
    float3 active_title = linear_rgb(float3(30, 30, 46));
    float3 active_number = linear_rgb(float3(88, 91, 112));
    float3 original_background = under_target ? MAUVE : background;
    float3 old_title = under_target ? active_title : inactive_title;
    float3 old_number = under_target ? active_number : inactive_number;
    float title_alpha = coverage_of(color.rgb, original_background, old_title);
    float number_alpha = coverage_of(color.rgb, original_background, old_number);
    bool number = distance(color.rgb, lerp(original_background, old_number, number_alpha))
                < distance(color.rgb, lerp(original_background, old_title, title_alpha));
    float3 title = lerp(inactive_title, active_title, fill);
    float3 index = lerp(inactive_number, active_number, fill);
    return float4(lerp(new_background, number ? index : title, number ? number_alpha : title_alpha), color.a);
}

public float4 fragment_main(float4 color, KittyTextures t, uniform KittyCustomShaderData d) {
    float2 pixel = 1.0 / float2(d.viewport_size_pixels);
    // Kitty reports where the terminal content starts on every frame, so
    // the tab row tracks font zoom without touching the terminal's pixels.
    float2 row = float2(d.central_area.y + d.central_area.w + GAP_PX * pixel.y,
                        1.0 - TOP_GAP_PX * pixel.y);
    float row_height = round((row.y - row.x) / pixel.y);
    // Each rounded cap occupies one JetBrains Mono cell.
    float cell_width = max(1.0, ceil(row_height * (24.0 / 53.0)));
    float now = float(d.timestamp_seconds % 60u) * 1000.0 + floor(d.timestamp_fraction * 1000.0);
    if (PASS == 3) return repair_settled_join(color, t, d, pixel, row, cell_width, now);
    if (PASS == 2) return paint_slide(color, t, d, pixel, row, cell_width, now);
    float2 size = floor(t.viewport.zw * float2(d.viewport_size_pixels));
    int2 location = int2(floor(t.pos * size));
    if (location.y != 0 || location.x >= 7) return float4(0.0, 0.0, 0.0, 1.0);
    if (PASS == 1) return read_pixel(t.a, pixel, location.x);
    return update_record(t, pixel, int(d.viewport_size_pixels.x), row, row_height,
                         cell_width, now, location.x);
}
