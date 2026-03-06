/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Bloom / glow with iterative separable Gaussian blur. Extracts bright pixels with soft knee, blurs with 4 H/V iterations, composites onto original. HDR-aware. Smooth, wide, artifact-free.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "threshold",  "LABEL": "Threshold",  "TYPE": "float", "DEFAULT": 0.8, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "soft_knee",  "LABEL": "Soft Knee",  "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "intensity",  "LABEL": "Intensity",  "TYPE": "float", "DEFAULT": 0.4, "MIN": 0.0, "MAX": 2.0 },
        { "NAME": "spread",     "LABEL": "Spread",     "TYPE": "float", "DEFAULT": 3.0, "MIN": 0.5, "MAX": 10.0 },
        { "NAME": "tint",       "LABEL": "Bloom Tint", "TYPE": "color", "DEFAULT": [ 1.0, 1.0, 1.0, 1.0 ] }
    ],
    "PASSES": [
        { "TARGET": "bright" },
        { "TARGET": "h1" },
        { "TARGET": "v1" },
        { "TARGET": "h2" },
        { "TARGET": "v2" },
        { "TARGET": "h3" },
        { "TARGET": "v3" },
        { "TARGET": "h4" },
        { "TARGET": "v4" },
        {}
    ]
}*/

const vec3 luma_coeff = vec3(0.2126, 0.7152, 0.0722);
const float offsets[3] = float[3](0.0, 1.3846153846, 3.2307692308);
const float weights[3] = float[3](0.2270270270, 0.3162162162, 0.0702702703);

vec4 blur9(sampler2D tex, vec2 uv, vec2 direction, float s) {
    vec2 px = direction * s / RENDERSIZE;
    vec4 c = IMG_NORM_PIXEL(tex, uv) * weights[0];
    for (int i = 1; i < 3; i++) {
        vec2 off = px * offsets[i];
        c += IMG_NORM_PIXEL(tex, uv + off) * weights[i];
        c += IMG_NORM_PIXEL(tex, uv - off) * weights[i];
    }
    return c;
}

void main() {
    vec2 uv = isf_FragNormCoord;
    float s = spread * 0.5;

    if (PASSINDEX == 0) {
        vec4 c = IMG_NORM_PIXEL(inputImage, uv);
        float L = dot(luma_coeff, c.rgb);
        float knee = threshold * soft_knee;
        float t = max(L - threshold + knee, 0.0);
        float blend = min(t / (2.0 * knee + 0.0001), 1.0);
        blend *= blend;
        gl_FragColor = vec4(c.rgb * blend, c.a);
    }
    else if (PASSINDEX == 1) gl_FragColor = blur9(bright, uv, vec2(1,0), s);
    else if (PASSINDEX == 2) gl_FragColor = blur9(h1, uv, vec2(0,1), s);
    else if (PASSINDEX == 3) gl_FragColor = blur9(v1, uv, vec2(1,0), s);
    else if (PASSINDEX == 4) gl_FragColor = blur9(h2, uv, vec2(0,1), s);
    else if (PASSINDEX == 5) gl_FragColor = blur9(v2, uv, vec2(1,0), s);
    else if (PASSINDEX == 6) gl_FragColor = blur9(h3, uv, vec2(0,1), s);
    else if (PASSINDEX == 7) gl_FragColor = blur9(v3, uv, vec2(1,0), s);
    else if (PASSINDEX == 8) gl_FragColor = blur9(h4, uv, vec2(0,1), s);
    else {
        vec4 original = IMG_NORM_PIXEL(inputImage, uv);
        vec3 bloom = IMG_NORM_PIXEL(v4, uv).rgb * intensity * tint.rgb;
        gl_FragColor = vec4(original.rgb + bloom, original.a);
    }
}
