/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "CRT scan lines: horizontal lines with configurable density, thickness, and brightness. Adds the classic CRT/retro monitor look. Optional rolling flicker simulates analog sync drift. Also useful as a subtle texture overlay for video art.",
    "CATEGORIES": [ "Stylize" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "line_count",    "LABEL": "Line Count",      "TYPE": "float", "DEFAULT": 300.0, "MIN": 50.0,  "MAX": 1080.0 },
        { "NAME": "line_darkness", "LABEL": "Line Darkness",    "TYPE": "float", "DEFAULT": 0.3,   "MIN": 0.0,   "MAX": 1.0 },
        { "NAME": "line_thickness","LABEL": "Line Thickness",   "TYPE": "float", "DEFAULT": 0.5,   "MIN": 0.1,   "MAX": 0.9 },
        { "NAME": "flicker_speed", "LABEL": "Flicker Speed",    "TYPE": "float", "DEFAULT": 0.0,   "MIN": 0.0,   "MAX": 5.0 },
        { "NAME": "flicker_amount","LABEL": "Flicker Amount",   "TYPE": "float", "DEFAULT": 0.0,   "MIN": 0.0,   "MAX": 0.3 },
        { "NAME": "curve",         "LABEL": "Screen Curve",     "TYPE": "float", "DEFAULT": 0.0,   "MIN": 0.0,   "MAX": 0.3 },
        { "NAME": "phosphor_blur", "LABEL": "Phosphor Bleed",   "TYPE": "float", "DEFAULT": 0.0,   "MIN": 0.0,   "MAX": 1.0 }
    ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;

    // Optional screen curvature (barrel distortion)
    if (curve > 0.001) {
        vec2 centered = uv * 2.0 - 1.0;
        float r2 = dot(centered, centered);
        centered *= 1.0 + curve * r2;
        uv = centered * 0.5 + 0.5;
        // Black outside screen
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            return;
        }
    }

    vec4 c = IMG_NORM_PIXEL(inputImage, uv);

    // Optional RGB phosphor bleed (horizontal subpixel shift)
    if (phosphor_blur > 0.01) {
        float shift = phosphor_blur / RENDERSIZE.x;
        float r = IMG_NORM_PIXEL(inputImage, uv + vec2(-shift, 0.0)).r;
        float b = IMG_NORM_PIXEL(inputImage, uv + vec2( shift, 0.0)).b;
        c.r = mix(c.r, r, 0.5);
        c.b = mix(c.b, b, 0.5);
    }

    // Scan line pattern
    float y = uv.y * line_count;
    float line = fract(y);
    // line goes 0to1 across each scanline. Dark band where line > thickness.
    float scanline = smoothstep(line_thickness, line_thickness + 0.05, line);
    float darkness = 1.0 - line_darkness * scanline;

    // Rolling flicker
    if (flicker_amount > 0.001 && flicker_speed > 0.001) {
        float flick = sin(uv.y * 3.14159 * 2.0 + TIME * flicker_speed * 6.28) * 0.5 + 0.5;
        darkness -= flicker_amount * flick;
    }

    c.rgb *= max(darkness, 0.0);

    gl_FragColor = c;
}
