/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Unsharp mask sharpening with iterative separable Gaussian blur. 2 H/V iterations build a smooth reference. Final pass extracts luminance detail and adds it back. Halo clamping prevents overshoot. Linear-safe.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "strength",   "LABEL": "Strength",   "TYPE": "float", "DEFAULT": 0.5,  "MIN": 0.0,  "MAX": 2.0 },
        { "NAME": "radius",     "LABEL": "Radius",     "TYPE": "float", "DEFAULT": 0.5,  "MIN": 0.01, "MAX": 2.0 },
        { "NAME": "halo_clamp", "LABEL": "Halo Limit", "TYPE": "float", "DEFAULT": 0.15, "MIN": 0.01, "MAX": 1.0 }
    ],
    "PASSES": [
        { "TARGET": "h1" },
        { "TARGET": "v1" },
        { "TARGET": "h2" },
        { "TARGET": "v2" },
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
    float s = radius * 0.7;

    if      (PASSINDEX == 0) gl_FragColor = blur9(inputImage, uv, vec2(1,0), s);
    else if (PASSINDEX == 1) gl_FragColor = blur9(h1, uv, vec2(0,1), s);
    else if (PASSINDEX == 2) gl_FragColor = blur9(v1, uv, vec2(1,0), s);
    else if (PASSINDEX == 3) gl_FragColor = blur9(h2, uv, vec2(0,1), s);
    else {
        vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
        vec3 blurred = IMG_NORM_PIXEL(v2, uv).rgb;
        float origL = dot(luma_coeff, orig.rgb);
        float blurL = dot(luma_coeff, blurred);
        float detail = clamp(origL - blurL, -halo_clamp, halo_clamp);
        float sharpL = origL + detail * strength;
        vec3 c = orig.rgb;
        if (origL > 1e-6) c *= sharpL / origL;
        gl_FragColor = vec4(max(c, 0.0), orig.a);
    }
}
