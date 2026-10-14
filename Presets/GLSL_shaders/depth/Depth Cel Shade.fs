/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Cel / toon shading. Computes a Lambertian light term against the reconstructed normal, quantises it into N levels, and overlays depth-Sobel outlines. The result looks drawn, not rendered. Adjust `lightDir` for the highlight side.",
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
        { "NAME": "levels", "TYPE": "long", "LABEL": "Shading steps",
          "VALUES": [2, 3, 4, 5, 6], "LABELS": ["2", "3", "4", "5", "6"], "DEFAULT": 3 },
        { "NAME": "lightDir", "TYPE": "point3D", "LABEL": "Light direction (view-space)",
          "DEFAULT": [0.4, 0.6, 0.8] },
        { "NAME": "edgeThreshold", "TYPE": "float", "LABEL": "Outline threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.08, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "edgeColor", "TYPE": "color", "LABEL": "Outline colour",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] },
        { "NAME": "ambient", "TYPE": "float", "LABEL": "Ambient floor",
          "DEFAULT": 0.3, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec2 texel = 1.0 / RENDERSIZE;

    if (dh_isSky(rawD)) {
        isf_FragColor = color; gl_FragDepth = rawD; return;
    }

    // Normal + outline in one gather.
    float nD[9];
    DH_GATHER_DEPTH_3X3(inputImage, uv, texel, nD);
    vec3 N = dh_reconstructViewNormalImproved(uv, texel, nD[4], nD[5], nD[3], nD[7], nD[1], camera.projection);

    vec3 L = normalize(lightDir);
    float lambert = max(dot(N, L), 0.0);
    float lit = ambient + (1.0 - ambient) * lambert;
    // ceil, not floor: the lit band reaches full brightness (floor capped
    // the brightest band at (levels-1)/levels and darkened the whole frame).
    float stepped = ceil(lit * float(levels)) / float(levels);

    vec3 shaded = color.rgb * stepped;

    // Sobel outline.
    float edge = dh_depthEdgeSobel(nD, camera.projection);
    float edgeMask = dh_smoothstep(edgeThreshold, edgeThreshold * 2.0 + 1e-4, edge);
    vec3 outRgb = mix(shaded, edgeColor.rgb, edgeMask);

    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
