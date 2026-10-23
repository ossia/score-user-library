/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "ALPHA": "premultiplied",
    "DESCRIPTION": "Quick Kuwahara: 4-quadrant variance-minimising filter producing flat painterly regions with preserved edges. Radius scales with depth so near stays sharp and far turns abstract. Simpler-than-Painterly-Blur alternative — fewer taps, cleaner edges.",
    "CATEGORIES": ["Post-process", "Stylise"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "nearRadius", "TYPE": "float", "LABEL": "Brush radius near (pixels)",
          "DEFAULT": 2.0, "MIN": 1.0, "MAX": 12.0 },
        { "NAME": "farRadius",  "TYPE": "float", "LABEL": "Brush radius far (pixels)",
          "DEFAULT": 6.0, "MIN": 1.0, "MAX": 24.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

void quadrant(vec2 uv, vec2 texel, float r, float ox, float oy,
              out vec4 mean, out float var)
{
    vec4 sum = vec4(0.0);
    vec4 sum2 = vec4(0.0);
    float n = 0.0;
    // 3x3 grid inside the quadrant.
    for (int j = 0; j <= 2; ++j) {
        for (int i = 0; i <= 2; ++i) {
            vec2 off = vec2(float(i) * r * 0.5 * ox, float(j) * r * 0.5 * oy) * texel;
            vec4 c = IMG_NORM_PIXEL_LOD0(inputImage, uv + off);
            sum  += c;
            sum2 += c * c;
            n += 1.0;
        }
    }
    mean = sum / n;
    vec4 v = sum2 / n - mean * mean;
    var = v.r + v.g + v.b + v.a;
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float t     = clamp(eye / depthScale, 0.0, 1.0);
    float r     = mix(nearRadius, farRadius, t);

    vec2 texel = 1.0 / RENDERSIZE;
    vec4 mA, mB, mC, mD; float vA, vB, vC, vD;
    quadrant(uv, texel, r, -1.0, -1.0, mA, vA);
    quadrant(uv, texel, r,  1.0, -1.0, mB, vB);
    quadrant(uv, texel, r, -1.0,  1.0, mC, vC);
    quadrant(uv, texel, r,  1.0,  1.0, mD, vD);

    vec4 best = mA; float bestV = vA;
    if (vB < bestV) { best = mB; bestV = vB; }
    if (vC < bestV) { best = mC; bestV = vC; }
    if (vD < bestV) { best = mD; bestV = vD; }

    isf_FragColor = best;
    gl_FragDepth = rawD;
}
