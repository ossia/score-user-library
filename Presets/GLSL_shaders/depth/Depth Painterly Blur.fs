/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "ALPHA": "premultiplied",
    "DESCRIPTION": "Painterly Kuwahara-lite filter with depth-scaled brush size. Divides a neighbourhood into four quadrants, picks the one with lowest variance, and uses its mean — yielding smooth painterly regions with preserved edges. Brush radius scales with eye depth: near stays detailed, far turns abstract.",
    "CATEGORIES": ["Post-process", "Focus"],

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
        { "NAME": "radiusNear", "TYPE": "float", "LABEL": "Brush radius at near (pixels)",
          "DEFAULT": 2.0, "MIN": 1.0, "MAX": 20.0 },
        { "NAME": "radiusFar", "TYPE": "float", "LABEL": "Brush radius at far (pixels)",
          "DEFAULT": 8.0, "MIN": 1.0, "MAX": 30.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units to reach far radius)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

// Sample quadrant mean and variance. `ox`, `oy` are signs for the quadrant
// corners (-1, +1). Size `r` is half the quadrant edge in pixels.
void quadrant(vec2 uv, vec2 texel, int r, float ox, float oy,
              out vec4 mean, out float variance)
{
    vec4 sum  = vec4(0.0);
    vec4 sum2 = vec4(0.0);
    float n = 0.0;
    for (int i = 0; i <= 3; ++i) {
        for (int j = 0; j <= 3; ++j) {
            float fx = float(i) * float(r) / 3.0;
            float fy = float(j) * float(r) / 3.0;
            vec2 off = vec2(fx * ox, fy * oy) * texel;
            vec4 c = IMG_NORM_PIXEL_LOD0(inputImage, uv + off);
            sum  += c;
            sum2 += c * c;
            n += 1.0;
        }
    }
    mean = sum / n;
    vec4 v = sum2 / n - mean * mean;
    variance = v.r + v.g + v.b + v.a;
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float t   = clamp(eye / depthScale, 0.0, 1.0);
    int r = int(mix(radiusNear, radiusFar, t));

    vec2 texel = 1.0 / RENDERSIZE;

    vec4 mA, mB, mC, mD; float vA, vB, vC, vD;
    quadrant(uv, texel, r, -1.0, -1.0, mA, vA);
    quadrant(uv, texel, r,  1.0, -1.0, mB, vB);
    quadrant(uv, texel, r, -1.0,  1.0, mC, vC);
    quadrant(uv, texel, r,  1.0,  1.0, mD, vD);

    vec4 best = mA;
    float bestV = vA;
    if (vB < bestV) { best = mB; bestV = vB; }
    if (vC < bestV) { best = mC; bestV = vC; }
    if (vD < bestV) { best = mD; bestV = vD; }

    isf_FragColor = best;
    gl_FragDepth = rawD;
}
