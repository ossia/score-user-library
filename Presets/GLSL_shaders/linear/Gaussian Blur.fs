/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Gaussian blur: iterative separable implementation with 4 H/V pass pairs. Each pass uses a small tight 9-tap kernel; repeated convolution builds a smooth wide Gaussian. No banding artifacts.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "radius",
            "LABEL": "Blur Radius",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 10.0
        }
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
    if (radius < 0.5) { gl_FragColor = IMG_NORM_PIXEL(inputImage, uv); return; }
    float s = radius * 0.5;

    if      (PASSINDEX == 0) gl_FragColor = blur9(inputImage, uv, vec2(1,0), s);
    else if (PASSINDEX == 1) gl_FragColor = blur9(h1, uv, vec2(0,1), s);
    else if (PASSINDEX == 2) gl_FragColor = blur9(v1, uv, vec2(1,0), s);
    else if (PASSINDEX == 3) gl_FragColor = blur9(h2, uv, vec2(0,1), s);
    else if (PASSINDEX == 4) gl_FragColor = blur9(v2, uv, vec2(1,0), s);
    else if (PASSINDEX == 5) gl_FragColor = blur9(h3, uv, vec2(0,1), s);
    else if (PASSINDEX == 6) gl_FragColor = blur9(v3, uv, vec2(1,0), s);
    else if (PASSINDEX == 7) gl_FragColor = blur9(h4, uv, vec2(0,1), s);
    else                     gl_FragColor = IMG_NORM_PIXEL(v4, uv);
}
