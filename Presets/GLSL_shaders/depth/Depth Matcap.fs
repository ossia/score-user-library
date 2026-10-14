/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Matcap (material-capture) lighting. Samples the provided matcap image using the reconstructed view-space normal as a 2D UV. Gives the scene a consistent studio-lit / clay / holographic appearance regardless of actual lighting. Drag any image into `matcapImage`.",
    "CATEGORIES": ["Post-process", "Lighting"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "matcapImage", "TYPE": "image", "LABEL": "Matcap texture (square, sphere-shaped content)" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "matcapAmount", "TYPE": "float", "LABEL": "Matcap blend (0 = scene, 1 = pure matcap)",
          "DEFAULT": 0.85, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "tint", "TYPE": "color", "LABEL": "Tint multiplier",
          "DEFAULT": [1.0, 1.0, 1.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    if (dh_isSky(rawD)) {
        isf_FragColor = color; gl_FragDepth = rawD; return;
    }

    vec2 texel = 1.0 / RENDERSIZE;
    float d0 = rawD;
    float dR = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2( texel.x, 0.0));
    float dL = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(-texel.x, 0.0));
    float dU = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0,  texel.y));
    float dD = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, -texel.y));
    vec3 N = dh_reconstructViewNormalImproved(uv, texel, d0, dR, dL, dU, dD, camera.projection);

    // Standard matcap trick: map XY of the view-space normal to [0, 1] UV
    // on a sphere-shaped matcap image.
    vec2 matUV = N.xy * 0.5 + 0.5;
    vec3 mat = IMG_NORM_PIXEL(matcapImage, matUV).rgb * tint.rgb;

    vec3 outRgb = mix(color.rgb, mat, matcapAmount);

    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
