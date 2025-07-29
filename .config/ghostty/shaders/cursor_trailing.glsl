// getSdfRoundedRectangle 函数:
// 计算点 `p` 到一个圆角矩形的有符号距离。
// `xy` 是矩形的中心，`b` 是矩形半宽/半高，`r` 是圆角半径。
float getSdfRoundedRectangle(in vec2 p, in vec2 xy, in vec2 b, in float r)
{
    // 基础矩形 SDF 计算
    vec2 d = abs(p - xy) - b + r;
    // 返回点到圆角矩形的有符号距离
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

// getSdfWedge 函数 (专为纯粹的三角形/楔形拖尾设计):
// 计算点 p 到一个从尖端扩展到平直底边的楔形（或拉伸三角形）的有符号距离。
// `a` 是起点（三角形顶点），`b` 是终点（底边中心），`halfWidth` 是底边的一半宽度。
float getSdfWedge(in vec2 p, in vec2 a, in vec2 b, in float halfWidth)
{
    vec2 dir = b - a; // 楔形的方向向量
    float len = length(dir); // 楔形的长度
    vec2 normalizedDir = dir / len; // 归一化的方向向量

    // 将点 p 投影到楔形的本地坐标系
    vec2 localP = p - a; // 将原点移到起点 a
    float h = dot(localP, normalizedDir); // 点 p 在楔形轴线上的投影位置 (0到len)

    // 计算点 p 距离楔形轴线的垂直距离
    float distToAxis = length(localP - normalizedDir * h);

    // 计算当前 h 位置对应的宽度（从 0 到 halfWidth 线性增长）
    // clamp 防止 h 超出范围，确保宽度始终在 [0, halfWidth]
    float currentHalfWidth = halfWidth * clamp(h / len, 0.0, 1.0);

    // 计算点到楔形侧边的 SDF。
    // 如果点在楔形轴线之外，则距离是垂直距离减去当前宽度。
    // 如果点在楔形轴线上，则距离就是负的当前宽度（在内部）。
    float sdf = distToAxis - currentHalfWidth;

    // 处理楔形的头部（尖端）和尾部（底边）
    // 头部：如果 h < 0，计算到尖端的距离。
    // `max(sdf, -h)` 确保在尖端之前，SDF 为正值 (在形状外部)。
    sdf = max(sdf, -h); 
    // 尾部：如果 h > len，计算到底边的距离。
    // `max(sdf, h - len)` 确保在底边之后，SDF 为正值 (在形状外部)。
    sdf = max(sdf, h - len); 

    return sdf;
}


// normalize 函数:
// 将屏幕坐标或大小归一化。
// `value` 是要归一化的向量，`isPosition` 指示是否为位置（需要考虑屏幕分辨率）。
vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

// antialising 函数:
// 根据距离计算抗锯齿因子。距离越小，抗锯齿效果越强。
float antialising(float distance) {
    // smoothstep 用于在距离接近 0 时平滑地从 1 降到 0，实现边缘模糊。
    // normalize(vec2(2., 2.), 0.).x 用于确定抗锯齿的宽度。
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

// getRectangleCenter 函数:
// 从矩形（vec4: x, y, width, height）获取中心点坐标。
vec2 getRectangleCenter(vec4 rectangle) {
    // x + width/2 得到中心 x 坐标
    // y - height/2 得到中心 y 坐标 (假设 y 轴向下为正)
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

// ease 函数:
// 一个缓动函数，用于平滑动画进度。
// pow(1.0 - x, 3.0) 使得动画在开始时变化快，在结束时变化慢。
float ease(float x) {
    return pow(1.0 - x, 3.0);
}

// saturate 函数:
// 饱和度调整函数，增加或减少颜色饱和度。
// `color` 是原始颜色，`factor` 是饱和度因子。
vec4 saturate(vec4 color, float factor) {
    // 计算颜色的灰度（亮度）
    float gray = dot(color, vec4(0.299, 0.587, 0.114, 0.)); // luminance
    // 在灰度颜色和原始颜色之间混合，factor 越大，原始颜色成分越多，饱和度越高。
    return mix(vec4(gray), color, factor);
}

vec4 TRAIL_COLOR = iCurrentCursorColor; // 拖尾颜色，取自当前光标颜色
const float DURATION = 0.2; // 动画持续时间，单位秒

// --- 关键调整：更严格的最小移动距离阈值，防止误触发拖尾 ---
// 这个阈值是光标移动距离的平方。
const float MIN_MOVEMENT_THRESHOLD_SQUARED = 0.0000001; 

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 始终先读取背景，确保拖尾和光标绘制在背景之上
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);

    // 计算光标的圆角半径，通常是光标高度的一半
    float cursorRadius = currentCursor.w * 0.5;

    // 计算光标移动距离的平方，比直接计算距离更高效（避免sqrt）
    float cursorDistanceSquared = dot(centerCC - centerCP, centerCC - centerCP);

    // --- 核心修复：更严格地判断光标是否在移动 ---
    bool isCursorActuallyMoving = cursorDistanceSquared > MIN_MOVEMENT_THRESHOLD_SQUARED;

    // 动画进度判断
    float timeSinceChange = iTime - iTimeCursorChange;
    bool isActiveAnimation = timeSinceChange < DURATION;

    // 拖尾的渲染条件：光标在发生显著移动，并且处于动画周期内。
    bool shouldRenderTrail = isCursorActuallyMoving && isActiveAnimation;


    const float maxMoveDistance = 0.2; // 用于 taperFactor 的最大距离阈值
    float taperFactor = smoothstep(0.0, maxMoveDistance, sqrt(cursorDistanceSquared)); 

    // --- 动态调整三角形底边宽度，如果静止则宽度为 0 ---
    float maxTrailHalfWidth = 0.0; // 默认情况下，拖尾宽度为 0 (不绘制)
    if (isCursorActuallyMoving) { // 只有在光标真正移动时才计算实际宽度
        vec2 movementVector = centerCC - centerCP;
        
        // 垂直移动和水平移动的宽度逻辑沿用之前版本（保持了动态适应性）
        if (abs(movementVector.x) > abs(movementVector.y)) {
            // 水平移动为主：底边宽度基于光标高度
            maxTrailHalfWidth = currentCursor.w * 0.5; // 可以根据需求调整此处的乘数
        } else {
            // 垂直移动为主：底边宽度基于光标宽度
            maxTrailHalfWidth = currentCursor.z * 0.5; // 可以根据需求调整此处的乘数
        }
        // 根据移动速度进一步调整宽度
        maxTrailHalfWidth = mix(maxTrailHalfWidth * 0.8, maxTrailHalfWidth * 1.2, taperFactor);
    }
    
    // 初始化拖尾 SDF 值为 1.0 (形状外部)，表示默认不绘制。
    float sdfTrail = 1.0; 
    if (shouldRenderTrail) {
        // 只有当 shouldRenderTrail 为 true 时，才实际计算拖尾的 SDF。
        sdfTrail = getSdfWedge(vu, centerCP, centerCC, maxTrailHalfWidth);
    }

    // 计算点到当前光标圆角矩形的有符号距离
    float sdfCurrentCursor = getSdfRoundedRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5, cursorRadius);

    float progress = clamp(timeSinceChange / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    float lineLength = distance(centerCC, centerCP);

    // --- 核心修改：遵循你提供的代码的混合逻辑来解决遮挡问题 ---
    vec4 finalRenderColor = fragColor; // 从背景色开始

    vec4 trailColor = TRAIL_COLOR;
    trailColor = saturate(trailColor, 3.0); 

    // 拖尾的不透明度。如果 shouldRenderTrail 为 false，则此处 opacity 为 0。
    float trailOpacity = antialising(sdfTrail) * (0.5 + 0.5 * taperFactor);
    
    // 1. 混合拖尾颜色到背景
    // `float(shouldRenderTrail)` 确保静止时不混合拖尾
    finalRenderColor = mix(finalRenderColor, trailColor, trailOpacity * float(shouldRenderTrail));

    // 2. 混合光标本体颜色。光标本体始终在拖尾之上。
    // 这行负责绘制光标的"边框"或"实体"部分。
    finalRenderColor = mix(finalRenderColor, TRAIL_COLOR, antialising(sdfCurrentCursor));
    
    // 3. 关键步骤：将光标本体内部的区域还原为背景色。
    // `step(sdfCurrentCursor, 0.)` 在光标内部（sdf < 0）返回 1.0，在外部返回 0.0。
    // 这样，光标内部的像素将混合回原始的背景色 `fragColor`，
    // 从而显示光标下方的字符，而不是被光标本体颜色或拖尾颜色覆盖。
    finalRenderColor = mix(finalRenderColor, fragColor, step(sdfCurrentCursor, 0.));

    // 4. 应用动画延伸效果。
    // 这行使得光标和其拖尾从旧位置“延伸”到新位置，但现在光标内部是透明的。
    // `step(sdfCurrentCursor, easedProgress * lineLength)` 控制动画的展开范围。
    fragColor = mix(fragColor, finalRenderColor, step(sdfCurrentCursor, easedProgress * lineLength));
}
