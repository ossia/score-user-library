/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Paper-fold effect: lays dark creases where depth discontinuities happen, and tints the whole scene toward a grainy paper colour. Looks like the scene is printed on paper that's been folded and unfolded. The paper is painted over the input, so a transparent background becomes paper too (at Paper tint amount).",
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
        { "NAME": "paperColor", "TYPE": "color", "LABEL": "Paper tint",
          "DEFAULT": [0.96, 0.93, 0.85, 1.0] },
        { "NAME": "paperAmount", "TYPE": "float", "LABEL": "Paper tint amount",
          "DEFAULT": 0.6, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "grainAmount", "TYPE": "float", "LABEL": "Paper grain amount",
          "DEFAULT": 0.15, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "grainScale", "TYPE": "float", "LABEL": "Grain scale",
          "DEFAULT": 200.0, "MIN": 10.0, "MAX": 1000.0 },
        { "NAME": "creaseStrength", "TYPE": "float", "LABEL": "Crease (depth edge) strength",
          "DEFAULT": 0.6, "MIN": 0.0, "MAX": 2.0 },
        { "NAME": "creaseThreshold", "TYPE": "float", "LABEL": "Crease threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.05, "MIN": 0.0, "MAX": 5.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec2 texel = 1.0 / RENDERSIZE;
    float nD[9];
    DH_GATHER_DEPTH_3X3(inputImage, uv, texel, nD);
    float edge = dh_depthEdgeSobel(nD, camera.projection);
    float crease = dh_smoothstep(creaseThreshold, creaseThreshold * 3.0 + 1e-4, edge) * creaseStrength;

    vec4 paper = dh_paintOver(color, paperColor.rgb, paperAmount);

    float grain = dh_valueNoise(uv * grainScale) - 0.5;
    paper.rgb += grain * grainAmount;
    paper.rgb *= (1.0 - crease);  // creases darken

    isf_FragColor = paper;
    gl_FragDepth = rawD;
}
