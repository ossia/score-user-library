/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Posterize and threshold effects operating on luminance to preserve hue. Posterize reduces tonal range to N steps; threshold creates hard black/white cutoff. Works correctly in linear light without hue shifts.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "mode",
            "LABEL": "Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Posterize (luminance)", "Posterize (per-channel)", "Threshold" ]
        },
        {
            "NAME": "levels",
            "LABEL": "Posterize Levels",
            "TYPE": "float",
            "DEFAULT": 6.0,
            "MIN": 2.0,
            "MAX": 32.0
        },
        {
            "NAME": "threshold_val",
            "LABEL": "Threshold",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 2.0
        },
        {
            "NAME": "threshold_softness",
            "LABEL": "Threshold Softness",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": 0.0,
            "MAX": 0.3
        },
        {
            "NAME": "fg_color",
            "LABEL": "Threshold Foreground",
            "TYPE": "color",
            "DEFAULT": [ 1.0, 1.0, 1.0, 1.0 ]
        },
        {
            "NAME": "bg_color",
            "LABEL": "Threshold Background",
            "TYPE": "color",
            "DEFAULT": [ 0.0, 0.0, 0.0, 1.0 ]
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    float n = floor(levels);

    if (mode == 0) {
        // Luminance posterize: quantize luminance, scale color proportionally
        float L = dot(luma, c);
        if (L <= 0.0) {
            gl_FragColor = vec4(vec3(0.0), orig.a);
            return;
        }
        float Lq = floor(L * n + 0.5) / n;
        c *= Lq / L;
        gl_FragColor = vec4(c, orig.a);
    }
    else if (mode == 1) {
        // Per-channel posterize (classic, may shift hue)
        c = floor(c * n + 0.5) / n;
        gl_FragColor = vec4(c, orig.a);
    }
    else {
        // Threshold on luminance
        float L = dot(luma, c);
        float t;
        if (threshold_softness > 0.001) {
            t = smoothstep(threshold_val - threshold_softness,
                           threshold_val + threshold_softness, L);
        } else {
            t = step(threshold_val, L);
        }
        gl_FragColor = vec4(mix(bg_color.rgb, fg_color.rgb, t), orig.a);
    }
}
