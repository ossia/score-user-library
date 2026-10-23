/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Newspaper-halftone dots whose dot frequency scales with depth: near = fine print, far = big coarse dots. Dot radius within each cell is driven by local luminance so the image still reads. Classic print-shop feel. By default the output is an opaque print: transparent areas of the input print as bare paper. With Transparent paper on, only the ink is drawn (in the ink colour) and the paper is transparent: alpha = ink coverage x input alpha, for layering the print over something else.",
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
        { "NAME": "dotsNear", "TYPE": "float", "LABEL": "Dots across screen (near)",
          "DEFAULT": 200.0, "MIN": 10.0, "MAX": 1000.0 },
        { "NAME": "dotsFar", "TYPE": "float", "LABEL": "Dots across screen (far)",
          "DEFAULT": 40.0, "MIN": 5.0, "MAX": 500.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 },
        { "NAME": "dotAngle", "TYPE": "float", "LABEL": "Screen angle (degrees)",
          "DEFAULT": 45.0, "MIN": 0.0, "MAX": 180.0 },
        { "NAME": "inkColor", "TYPE": "color", "LABEL": "Ink colour",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] },
        { "NAME": "paperColor", "TYPE": "color", "LABEL": "Paper colour",
          "DEFAULT": [1.0, 1.0, 1.0, 1.0] },
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
    float dots  = mix(dotsNear, dotsFar, t);

    float ang = radians(dotAngle);
    float c = cos(ang), s = sin(ang);
    // Aspect-corrected so the cells (and dots) are round: `dots` counts
    // them across the screen width.
    vec2 p = (uv - 0.5) * vec2(1.0, RENDERSIZE.y / RENDERSIZE.x);
    p = mat2(c, -s, s, c) * p;
    vec2 cellP = p * dots;
    vec2 cellF = fract(cellP) - 0.5;
    float cellR = length(cellF);

    // Opaque print: the input is laid on the paper first, so a transparent
    // area prints as bare paper.
    float luma = transparentPaper ? dh_luma(color.rgb)
                                  : dh_luma(mix(paperColor.rgb, color.rgb, color.a));
    // Dot fills more as luma goes down (ink). 0.5 is the cell corner.
    float dotRadius = (1.0 - luma) * 0.55;
    float dot_ = smoothstep(dotRadius + 0.05, dotRadius - 0.05, cellR)
               * clamp(dotRadius / 0.05, 0.0, 1.0);  // white stays bare paper

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
