/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Hand-stippled look: replaces the scene with stochastic ink dots whose density follows the inverted luminance (dark areas dotted densely, light areas sparsely) and whose size scales with depth. Etching / engraving aesthetic. By default the output is an opaque print: transparent areas of the input print as bare paper. With Transparent paper on, only the ink is drawn (in the ink colour) and the paper is transparent: alpha = ink coverage x input alpha, for layering the print over something else.",
    "CATEGORIES": ["Post-process", "Stylise"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "dotDensity", "TYPE": "float", "LABEL": "Dot density (dots across screen)",
          "DEFAULT": 180.0, "MIN": 20.0, "MAX": 800.0 },
        { "NAME": "nearDotSize", "TYPE": "float", "LABEL": "Dot size near",
          "DEFAULT": 0.25, "MIN": 0.05, "MAX": 0.5 },
        { "NAME": "farDotSize", "TYPE": "float", "LABEL": "Dot size far",
          "DEFAULT": 0.45, "MIN": 0.05, "MAX": 0.5 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 },
        { "NAME": "inkColor", "TYPE": "color", "LABEL": "Ink colour",
          "DEFAULT": [0.05, 0.05, 0.08, 1.0] },
        { "NAME": "paperColor", "TYPE": "color", "LABEL": "Paper colour",
          "DEFAULT": [0.96, 0.93, 0.85, 1.0] },
        { "NAME": "transparentPaper", "TYPE": "bool", "LABEL": "Transparent paper",
          "DEFAULT": false }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float t     = clamp(eye / depthScale, 0.0, 1.0);
    float dotMax = mix(nearDotSize, farDotSize, t);

    float aspect = RENDERSIZE.x / RENDERSIZE.y;
    vec2 cellP = vec2(uv.x * aspect, uv.y) * dotDensity;
    vec2 i = floor(cellP);
    vec2 f = fract(cellP) - 0.5;

    // Jittered dot centre per cell.
    vec2 jitter = (dh_hash22(i) - 0.5) * 0.6;
    float r = length(f - jitter);

    // Opaque print: the input is laid on the paper first, so a transparent
    // area prints as bare paper.
    float luma = transparentPaper ? dh_luma(color.rgb)
                                  : dh_luma(mix(paperColor.rgb, color.rgb, color.a));
    // Dense ink where luma low. Dot radius grows as luma drops.
    float dotR = dotMax * (1.0 - luma);
    float dot_ = smoothstep(dotR, dotR - 0.05, r);

    if(transparentPaper)
    {
        isf_FragColor = vec4(inkColor.rgb, dot_ * color.a);
    }
    else
    {
        vec3 outRgb = mix(paperColor.rgb, inkColor.rgb, dot_);
        isf_FragColor = vec4(outRgb, 1.0);
    }
    gl_FragDepth = rawD;
}
