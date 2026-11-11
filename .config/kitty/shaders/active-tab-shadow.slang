#language slang 2026

import kitty_custom_shader_types;

// This matches the 3 pt inner tab-bar margin on a Retina display.
static const float GAP_PX = 6.0;
static const float OFFSET_PX = 2.0;
static const float BLUR_PX = 4.0;
static const float OPACITY = 0.12;
// Catppuccin Mocha Mauve (#CBA6F7) in linear RGB.
static const float3 ACTIVE_TAB_COLOR = float3(0.597202, 0.381326, 0.930111);

public float4 fragment_main(float4 color, KittyTextures t, uniform KittyCustomShaderData d) {
    float2 pixel = 1.0 / float2(d.viewport_size_pixels);
    float content_top = d.central_area.y + d.central_area.w;
    float depth = GAP_PX - (t.pos.y - content_top) / pixel.y;
    if (depth < 0.0 || depth >= GAP_PX || content_top >= 1.0 - GAP_PX * pixel.y
        || distance(color.rgb, d.background.rgb) > 0.025)
        return color;

    // Sample just inside the bottom edge of the active pill. Symmetric taps
    // soften both ends equally and let the shadow follow changes in tab width.
    float sample_y = content_top + (GAP_PX + 4.0) * pixel.y;
    float coverage = 0.0;
    float total_weight = 0.0;
    for (int tap = -3; tap <= 3; ++tap) {
        float dx = float(tap) * 2.0;
        float normalized = dx / (0.75 * BLUR_PX);
        float weight = exp(-0.5 * normalized * normalized);
        float3 sample_color = t.backbuffer.Sample(float2(t.pos.x + dx * pixel.x, sample_y)).rgb;
        float matching = 1.0 - smoothstep(0.025, 0.1, distance(sample_color, ACTIVE_TAB_COLOR));
        coverage += weight * matching;
        total_weight += weight;
    }
    float fade = 1.0 - smoothstep(-OFFSET_PX, OFFSET_PX + BLUR_PX, depth);
    float opacity = OPACITY * coverage / total_weight * fade;
    return float4(color.rgb * pow(1.0 - opacity, 2.2), color.a);
}
