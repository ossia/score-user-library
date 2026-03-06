/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Tilt shift / selective focus using iterative separable Gaussian blur (4 H/V iterations). Final pass mixes sharp original with blurred image based on distance from focal line. Cinema-quality miniature/diorama effect.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "focus_position", "LABEL": "Focus Position",     "TYPE": "float", "DEFAULT": 0.5,  "MIN": 0.0,   "MAX": 1.0 },
        { "NAME": "focus_width",    "LABEL": "Focus Width",        "TYPE": "float", "DEFAULT": 0.15, "MIN": 0.01,  "MAX": 0.5 },
        { "NAME": "blur_amount",    "LABEL": "Blur Amount",        "TYPE": "float", "DEFAULT": 3.0, "MIN": 0.0,   "MAX": 10.0 },
        { "NAME": "angle",          "LABEL": "Angle (degrees)",    "TYPE": "float", "DEFAULT": 0.0,  "MIN": -90.0, "MAX": 90.0 },
        { "NAME": "saturation_boost","LABEL": "Saturation Boost",  "TYPE": "float", "DEFAULT": 0.1,  "MIN": 0.0,   "MAX": 0.5 }
    ],
    "PASSES": [
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

float focusMask(vec2 uv) {
    float rad = angle * 3.14159265 / 180.0;
    vec2 dir = vec2(sin(rad), cos(rad));
    float d = abs(dot(uv - vec2(0.5, focus_position), dir));
    return smoothstep(focus_width * 0.5, focus_width * 0.5 + focus_width, d);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    float s = blur_amount * 0.5;

    if      (PASSINDEX == 0) gl_FragColor = blur9(inputImage, uv, vec2(1,0), s);
    else if (PASSINDEX == 1) gl_FragColor = blur9(h1, uv, vec2(0,1), s);
    else if (PASSINDEX == 2) gl_FragColor = blur9(v1, uv, vec2(1,0), s);
    else if (PASSINDEX == 3) gl_FragColor = blur9(h2, uv, vec2(0,1), s);
    else if (PASSINDEX == 4) gl_FragColor = blur9(v2, uv, vec2(1,0), s);
    else if (PASSINDEX == 5) gl_FragColor = blur9(h3, uv, vec2(0,1), s);
    else if (PASSINDEX == 6) gl_FragColor = blur9(v3, uv, vec2(1,0), s);
    else if (PASSINDEX == 7) gl_FragColor = blur9(h4, uv, vec2(0,1), s);
    else {
        vec4 sharp = IMG_NORM_PIXEL(inputImage, uv);
        vec4 blurred = IMG_NORM_PIXEL(v4, uv);
        float mask = focusMask(uv);
        vec3 c = mix(sharp.rgb, blurred.rgb, mask);
        if (saturation_boost > 0.0 && mask > 0.01) {
            float L = dot(luma_coeff, c);
            c = mix(vec3(L), c, 1.0 + saturation_boost * mask);
        }
        gl_FragColor = vec4(c, sharp.a);
    }
}
