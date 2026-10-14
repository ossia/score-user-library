/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Curvature shading via the Laplacian of linearised depth. Negative Laplacian (concave — cavities, valleys) gets one colour, positive (convex — ridges, peaks) another; neighbour pairs straddling a silhouette are ignored. Sculptural look on organic scenes, great on rocks and flesh.",
    "CATEGORIES": ["Post-process", "Outlines"],

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
        { "NAME": "convexColor", "TYPE": "color", "LABEL": "Convex ridge colour",
          "DEFAULT": [1.0, 0.95, 0.8, 1.0] },
        { "NAME": "concaveColor", "TYPE": "color", "LABEL": "Concave cavity colour",
          "DEFAULT": [0.1, 0.05, 0.15, 1.0] },
        { "NAME": "strength", "TYPE": "float", "LABEL": "Curvature strength",
          "DEFAULT": 4.0, "MIN": 0.0, "MAX": 50.0 },
        { "NAME": "mixAmount", "TYPE": "float", "LABEL": "Mix (0 = scene, 1 = full curvature)",
          "DEFAULT": 0.7, "MIN": 0.0, "MAX": 1.0 }
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

    // Linearise the centre and four cardinal neighbours; 5-point Laplacian
    // in eye-space depth, relative to the centre depth so the look does not
    // fade with distance.
    float l0 = dh_linearizeDepth(nD[4], camera.projection);
    float d[4];
    d[0] = dh_linearizeDepth(nD[1], camera.projection) - l0;
    d[1] = dh_linearizeDepth(nD[7], camera.projection) - l0;
    d[2] = dh_linearizeDepth(nD[5], camera.projection) - l0;
    d[3] = dh_linearizeDepth(nD[3], camera.projection) - l0;

    // Range check: a neighbour across a silhouette (more than 5% of the
    // depth away) is another surface, not curvature of this one. Without it
    // every silhouette reads as a huge ridge/valley pair.
    // Pairs (N,S) and (E,W) are kept or dropped TOGETHER: dropping one tap
    // of a pair leaves a one-sided first difference, which reads the limb
    // of every convex object as a crease.
    float lap = 0.0, n = 0.0;
    for (int i = 0; i < 4; i += 2) {
        float lim = 0.05 * l0;
        if (abs(d[i]) < lim && abs(d[i + 1]) < lim) { lap += d[i] + d[i + 1]; n += 1.0; }
    }
    lap = (n > 0.0) ? lap * 2.0 / n / max(l0, DH_EPSILON) : 0.0;

    // Sign: eye depth grows away from the camera, so lap > 0 means the
    // neighbours are FARTHER than the centre -- the centre bulges towards the
    // viewer: convex (ridge). lap < 0: centre sits behind its neighbours,
    // concave (valley). The previous version had these two colours swapped.
    // Magnitude is squashed by tanh(strength * 100 * |lap|) into [0, 1]
    // (lap is now relative, ~1e-3 on visible curvature).
    float shaped = tanh(strength * 100.0 * abs(lap));
    vec3 curvColor = lap > 0.0 ? convexColor.rgb : concaveColor.rgb;
    vec3 mixed = mix(color.rgb, curvColor, shaped * mixAmount);

    isf_FragColor = vec4(mixed, color.a);
    gl_FragDepth = rawD;
}
