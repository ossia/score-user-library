/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "LED panel simulator: renders the image as if displayed on a physical LED wall or matrix. Individual LED dots (round, square, or diamond) are visible with configurable gap between them. Useful for stage previz, retro aesthetics, and creative effects.",
    "CATEGORIES": [ "Stylize" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "led_count",    "LABEL": "LED Count (horizontal)", "TYPE": "float", "DEFAULT": 64.0, "MIN": 8.0, "MAX": 256.0 },
        { "NAME": "led_gap",      "LABEL": "Gap Size",               "TYPE": "float", "DEFAULT": 0.25, "MIN": 0.0, "MAX": 0.6 },
        { "NAME": "led_softness", "LABEL": "LED Softness",           "TYPE": "float", "DEFAULT": 0.1,  "MIN": 0.0, "MAX": 0.5 },
        {
            "NAME": "led_shape",
            "LABEL": "LED Shape",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Round", "Square", "Diamond" ]
        },
        { "NAME": "bg_color",     "LABEL": "Background",             "TYPE": "color", "DEFAULT": [ 0.02, 0.02, 0.02, 1.0 ] },
        { "NAME": "brightness",   "LABEL": "LED Brightness",         "TYPE": "float", "DEFAULT": 1.2,  "MIN": 0.5, "MAX": 3.0 },
        { "NAME": "bleed",        "LABEL": "Light Bleed",            "TYPE": "float", "DEFAULT": 0.0,  "MIN": 0.0, "MAX": 0.3 }
    ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;

    // Calculate aspect-corrected LED grid
    float aspect = RENDERSIZE.x / RENDERSIZE.y;
    float ledCountY = led_count / aspect;
    vec2 gridSize = vec2(led_count, ledCountY);

    // Which LED cell are we in?
    vec2 cellIndex = floor(uv * gridSize);
    vec2 cellCenter = (cellIndex + 0.5) / gridSize;
    vec2 cellLocal = fract(uv * gridSize) - 0.5; // -0.5 to 0.5

    // Sample the image at the LED center (quantized)
    vec4 ledColor = IMG_NORM_PIXEL(inputImage, cellCenter);
    ledColor.rgb *= brightness;

    // LED shape mask
    float dist;
    if (led_shape == 0) {
        // Round
        dist = length(cellLocal) * 2.0;
    } else if (led_shape == 1) {
        // Square (Chebyshev distance)
        dist = max(abs(cellLocal.x), abs(cellLocal.y)) * 2.0;
    } else {
        // Diamond (Manhattan distance)
        dist = (abs(cellLocal.x) + abs(cellLocal.y)) * 2.0;
    }

    float ledSize = 1.0 - led_gap;
    float mask = 1.0 - smoothstep(ledSize - led_softness, ledSize, dist);

    // Optional light bleed: add a dim glow beyond the LED boundary
    float glow = 0.0;
    if (bleed > 0.001) {
        glow = exp(-dist * dist * 4.0 / (bleed * bleed)) * bleed;
    }

    vec3 result = mix(bg_color.rgb, ledColor.rgb, mask + glow);

    gl_FragColor = vec4(result, 1.0);
}
