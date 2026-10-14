/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Posterisation (colour-level quantisation) whose level count varies with depth. Near pixels can stay full-colour, far pixels drop to chunky banded flats — or vice versa. Great for flattening distant clutter.",
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
        { "NAME": "levelsNear", "TYPE": "float", "LABEL": "Colour levels near (per channel)",
          "DEFAULT": 32.0, "MIN": 2.0, "MAX": 256.0 },
        { "NAME": "levelsFar",  "TYPE": "float", "LABEL": "Colour levels far (per channel)",
          "DEFAULT": 4.0,  "MIN": 2.0, "MAX": 256.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
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
    float levels = max(mix(levelsNear, levelsFar, t), 2.0);

    // `levels` values per channel from 0 to 1 inclusive, rounded to the
    // nearest (floor() lost half a level and crushed dark areas to black).
    float steps = levels - 1.0;
    vec3 q = floor(clamp(color.rgb, 0.0, 1.0) * steps + 0.5) / steps;
    isf_FragColor = vec4(q, color.a);
    gl_FragDepth = rawD;
}
