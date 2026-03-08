/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Sobel edge detection operating on luminance. Cleaner than per-channel edge detection. Adjustable threshold with soft falloff. Can overlay on original, show edges only, or use custom colors.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "mode",
            "LABEL": "Display Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Edges Only", "Overlay on Original", "Original * Edges" ]
        },
        {
            "NAME": "strength",
            "LABEL": "Strength",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.1,
            "MAX": 5.0
        },
        {
            "NAME": "threshold_val",
            "LABEL": "Threshold",
            "TYPE": "float",
            "DEFAULT": 0.05,
            "MIN": 0.0,
            "MAX": 0.5
        },
        {
            "NAME": "edge_color",
            "LABEL": "Edge Color",
            "TYPE": "color",
            "DEFAULT": [ 1.0, 1.0, 1.0, 1.0 ]
        },
        {
            "NAME": "bg_color",
            "LABEL": "Background Color",
            "TYPE": "color",
            "DEFAULT": [ 0.0, 0.0, 0.0, 1.0 ]
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

float getLuma(vec2 uv) {
    return dot(luma, IMG_NORM_PIXEL(inputImage, uv).rgb);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec2 px = 1.0 / RENDERSIZE;

    // 3*3 Sobel
    float tl = getLuma(uv + vec2(-px.x, px.y));
    float t  = getLuma(uv + vec2(0,     px.y));
    float tr = getLuma(uv + vec2( px.x, px.y));
    float l  = getLuma(uv + vec2(-px.x, 0));
    float r  = getLuma(uv + vec2( px.x, 0));
    float bl = getLuma(uv + vec2(-px.x,-px.y));
    float b  = getLuma(uv + vec2(0,    -px.y));
    float br = getLuma(uv + vec2( px.x,-px.y));

    float gx = -tl - 2.0*l - bl + tr + 2.0*r + br;
    float gy = -tl - 2.0*t - tr + bl + 2.0*b + br;
    float edge = length(vec2(gx, gy)) * strength;

    // Soft threshold
    edge = smoothstep(threshold_val, threshold_val + 0.05, edge);

    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);

    if (mode == 0) {
        // Edges only with custom colors
        gl_FragColor = vec4(mix(bg_color.rgb, edge_color.rgb, edge), orig.a);
    } else if (mode == 1) {
        // Overlay: edges drawn on top of original
        gl_FragColor = vec4(mix(orig.rgb, edge_color.rgb, edge * 0.8), orig.a);
    } else {
        // Multiply: original weighted by edge strength
        gl_FragColor = vec4(orig.rgb * edge, orig.a);
    }
}
