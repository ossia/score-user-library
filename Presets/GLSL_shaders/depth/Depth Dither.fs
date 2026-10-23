/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Bayer 4x4 ordered dither with depth-scaled strength. Near pixels remain smooth; far pixels are quantised to `levels` values per channel (black and white included) with classic Gameboy / early-PC dither stipple. A nostalgic lo-fi haze for backgrounds. Depth weight 0 applies the full effect everywhere.",
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
        { "NAME": "dither", "TYPE": "float", "LABEL": "Dither amount (1 / (levels - 1) = one full level)",
          "DEFAULT": 0.2, "MIN": 0.0, "MAX": 0.5 },
        { "NAME": "depthWeight", "TYPE": "float", "LABEL": "Depth weight (1 = full depth-scaled, 0 = uniform)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 },
        { "NAME": "levels", "TYPE": "float", "LABEL": "Colour levels per channel (far)",
          "DEFAULT": 6.0, "MIN": 2.0, "MAX": 256.0 }
    ]
}*/

#include "depth_helpers.glsl"

// Standard Bayer 4x4 — values in [0, 15] / 16.
float bayer4x4(ivec2 p)
{
    int x = p.x & 3;
    int y = p.y & 3;
    int i = x + y * 4;
    // Hard-coded matrix:  0  8  2 10 / 12 4 14 6 / 3 11 1 9 / 15 7 13 5.
    if (i ==  0) return  0.0/16.0;
    if (i ==  1) return  8.0/16.0;
    if (i ==  2) return  2.0/16.0;
    if (i ==  3) return 10.0/16.0;
    if (i ==  4) return 12.0/16.0;
    if (i ==  5) return  4.0/16.0;
    if (i ==  6) return 14.0/16.0;
    if (i ==  7) return  6.0/16.0;
    if (i ==  8) return  3.0/16.0;
    if (i ==  9) return 11.0/16.0;
    if (i == 10) return  1.0/16.0;
    if (i == 11) return  9.0/16.0;
    if (i == 12) return 15.0/16.0;
    if (i == 13) return  7.0/16.0;
    if (i == 14) return 13.0/16.0;
    return 5.0/16.0;
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float t     = clamp(eye / depthScale, 0.0, 1.0);
    // Effect weight: 1 far (or everywhere with depthWeight 0), 0 at the camera.
    float w     = mix(1.0, t, depthWeight);

    ivec2 ip = ivec2(isf_FragCoord.xy);
    float b = bayer4x4(ip) - 0.5;

    // `levels` values per channel from 0 to 1, rounded to the nearest, so
    // the image keeps its brightness (floor() lost half a level and crushed
    // dark scenes to black). The level count rises to 256 (smooth) near.
    float steps = max(mix(256.0, levels, w) - 1.0, 1.0);
    vec3 dithered = color.rgb + b * dither * w;
    vec3 q = floor(clamp(dithered, 0.0, 1.0) * steps + 0.5) / steps;

    isf_FragColor = vec4(q, color.a);
    gl_FragDepth = rawD;
}
