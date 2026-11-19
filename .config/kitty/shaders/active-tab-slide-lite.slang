#language slang 2026

import kitty_custom_shader_types;

// Horizontal corner radius in pixels at the reference 53 px tab height.
static const float CORNER_RADIUS = 24.8;
// Center the outline on the first and last tab pixels for vertical antialiasing.
static const float HIGHLIGHT_Y_INSET_PX = 0.5;
static const float MARGIN_PX = 12.0;
static const int MARKER_OFFSETS[4] = { 0, 32, 48, 64 };

// Match these sRGB values (0–255) to sliding-tabs.conf.
static const float3 ACTIVE_BACKGROUND = float3(203, 166, 247);
static const float3 ACTIVE_TITLE = float3(30, 30, 46);
static const float3 ACTIVE_INDEX = float3(88, 91, 112);
static const float3 INACTIVE_TITLE = float3(205, 214, 244);
static const float3 INACTIVE_INDEX = float3(147, 153, 178);

float linear_channel(float srgb) {
    float value = srgb / 255.0;
    return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4);
}

float3 linear_rgb(float3 srgb) {
    return float3(linear_channel(srgb.r), linear_channel(srgb.g), linear_channel(srgb.b));
}

int read_marker(KittyTexture texture, float2 pixel, float x, float y, int signature) {
    float3 sample_color = texture.Sample(float2(x * pixel.x, y)).rgb;
    if (any(sample_color < 0.10)) return -1;
    float3 srgb = 1.055 * pow(sample_color, float3(1.0 / 2.4)) - 0.055;
    int3 levels = int3(round((srgb * 255.0 - 96.0) / 5.0));
    if (any(levels < 0) || any(levels > 31)) return -1;
    int value = (levels.x << 10) | (levels.y << 5) | levels.z;
    return (value >> 13) == signature ? value & 8191 : -1;
}

float coverage_of(float3 color, float3 background, float3 ink) {
    float3 delta = ink - background;
    return saturate(dot(color - background, delta) / max(dot(delta, delta), 0.00001));
}

struct CornerSamples {
    float4 insets;
    float4 coverage;
};

// Fit the measured inset macOS corner profile, normalized to the tab height.
CornerSamples sample_corners(float row_y, float row_height) {
    float y_inset = min(HIGHLIGHT_Y_INSET_PX, (row_height - 1.0) * 0.5);
    float radius = clamp(CORNER_RADIUS * (row_height / 53.0), 0.0, row_height * 0.75);
    float vertical_radius = max(0.001, min(radius * (23.1 / 24.8), row_height * 0.5 - y_inset));
    // Integrate coverage over the pixel's height as well as its width.
    float4 y = row_y + float4(-0.375, -0.125, 0.125, 0.375);
    float4 distance_from_edge = min(y, row_height - y) - y_inset;
    float4 u = 1.0 - sqrt(saturate(distance_from_edge / vertical_radius));
    return { radius * pow(u, float4(2.14)), step(float4(0.0), distance_from_edge) };
}

float4 paint_slide(float4 color, float x, CornerSamples corners, float3 background,
                   float3 highlight, float2 visible, float2 target) {
    bool under_target = x >= target.x && x < target.y;
    float distance_to_side = min(x - visible.x, visible.y - x);
    if (!under_target && distance_to_side < 0.0) return color;

    float4 coverage = corners.coverage * saturate(distance_to_side - corners.insets + 0.5);
    float fill = dot(coverage, float4(0.25));
    float3 new_background = lerp(background, highlight, fill);

    // Recover text coverage from the title and index colors and composite it
    // in place over the moving fill. The labels never translate.
    float3 inactive_title = linear_rgb(INACTIVE_TITLE);
    float3 inactive_number = linear_rgb(INACTIVE_INDEX);
    float3 active_title = linear_rgb(ACTIVE_TITLE);
    float3 active_number = linear_rgb(ACTIVE_INDEX);
    float3 original_background = under_target ? highlight : background;
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


float static_corner_coverage(KittyTextures t, float2 pixel, float sample_y, float inset,
                             float3 background, float3 highlight) {
    float2 sample_x = t.pos.x / pixel.x + float2(-inset, inset);
    float3 left = t.backbuffer.Sample(float2(sample_x.x * pixel.x, sample_y)).rgb;
    float3 right = t.backbuffer.Sample(float2(sample_x.y * pixel.x, sample_y)).rgb;
    // Kitty can extend the first tab's fill into the window margin.
    float left_edge = saturate(sample_x.x - MARGIN_PX + 0.5);
    float right_edge = saturate(1.0 / pixel.x - MARGIN_PX - sample_x.y + 0.5);
    return min(coverage_of(left, background, highlight) * left_edge,
               coverage_of(right, background, highlight) * right_edge);
}

float4 paint_static_corners(float4 color, KittyTextures t, float2 pixel, float sample_y,
                            CornerSamples corners, float3 background, float3 highlight) {
    float fill = dot(corners.coverage, float4(0.25));
    if (fill >= 1.0 && !any(corners.insets > 0.0)) return color;
    if (distance(color.rgb, highlight) >= 0.035) return color;
    // The status text can share the highlight color. Only round a tab's fill.
    float3 top_fill = t.backbuffer.Sample(float2(t.pos.x, sample_y)).rgb;
    if (distance(top_fill, highlight) >= 0.035) return color;

    // Shift the native fill's edge along the top scanline. Each bilinear
    // sample supplies the horizontal coverage for one vertical subsample.
    if (fill > 0.0 && any(corners.insets > 0.0)) {
        float furthest = max(corners.insets.x, corners.insets.w);
        float outer = static_corner_coverage(t, pixel, sample_y, furthest, background, highlight);
        if (outer < 0.999) {
            fill = 0.0;
            for (int i = 0; i < 4; ++i) {
                if (corners.coverage[i] <= 0.0) continue;
                fill += corners.insets[i] == furthest ? outer :
                        static_corner_coverage(t, pixel, sample_y, corners.insets[i], background, highlight);
            }
            fill *= 0.25;
        }
    }
    return float4(lerp(background, color.rgb, fill), color.a);
}

public float4 fragment_main(float4 color, KittyTextures t, uniform KittyCustomShaderData d) {
    float2 pixel = 1.0 / float2(d.viewport_size_pixels);
    float bottom = d.central_area.y + d.central_area.w;
    float top = 1.0 - MARGIN_PX * pixel.y;
    if (t.pos.y < bottom || t.pos.y >= top) return color;

    float row_height = round((top - bottom) / pixel.y);
    float cell_width = max(1.0, ceil(row_height * (24.0 / 53.0)));
    int columns = int(floor((float(d.viewport_size_pixels.x) - 2.0 * MARGIN_PX) / cell_width));
    float sample_y = (top + bottom) * 0.5;
    float x = t.pos.x / pixel.x;
    float3 background = d.background.rgb;
    if (x < MARGIN_PX || x >= float(d.viewport_size_pixels.x) - MARGIN_PX)
        return float4(background, color.a);

    CornerSamples corners = sample_corners((top - t.pos.y) / pixel.y, row_height);
    float3 highlight = linear_rgb(ACTIVE_BACKGROUND);

    // The Python renderer supplies one small record in four unused cells.
    // Erase those cells from the final frame after reading the coordinates.
    for (int i = 0; i < 4; ++i) {
        int column = columns - 4 - MARKER_OFFSETS[i];
        if (column < 0) continue;
        float start = MARGIN_PX + float(column) * cell_width;
        float marker_x = start + 0.5 * cell_width;
        int left = read_marker(t.backbuffer, pixel, marker_x, sample_y, 1);
        if (left < int(MARGIN_PX)) continue;
        int right = read_marker(t.backbuffer, pixel, marker_x + cell_width, sample_y, 2);
        int target_left = read_marker(t.backbuffer, pixel, marker_x + 2.0 * cell_width, sample_y, 3);
        int target_right = read_marker(t.backbuffer, pixel, marker_x + 3.0 * cell_width, sample_y, 2);
        if (right <= left || target_left < int(MARGIN_PX) || target_right <= target_left
            || float(right) > start || float(target_right) > start) continue;
        if (x >= start && x < start + 4.0 * cell_width)
            return float4(background, color.a);
        return paint_slide(color, x, corners, background, highlight,
                           float2(float(left), float(right)), float2(float(target_left), float(target_right)));
    }
    return paint_static_corners(color, t, pixel, top - 0.5 * pixel.y, corners, background, highlight);
}
