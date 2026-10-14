/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Contact shadow: raymarches the scene depth along a light direction for a few steps and shadows fragments whose ray hits closer geometry. Adds the tight contact darkening that regular shadow maps miss. Purely depth-based — no shadow map needed.",
    "CATEGORIES": ["Post-process", "Lighting"],

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
        { "NAME": "lightDir", "TYPE": "point3D", "LABEL": "Light direction (world, pointing FROM light TO scene)",
          "DEFAULT": [-0.5, -1.0, -0.3] },
        { "NAME": "rayLength", "TYPE": "float", "LABEL": "Ray length (world units)",
          "DEFAULT": 0.5, "MIN": 0.01, "MAX": 10.0 },
        { "NAME": "stepCount", "TYPE": "long", "LABEL": "Steps per ray",
          "VALUES": [4, 8, 16, 32], "LABELS": ["4", "8", "16", "32"], "DEFAULT": 8 },
        { "NAME": "thickness", "TYPE": "float", "LABEL": "Occluder thickness (world units)",
          "DEFAULT": 0.2, "MIN": 0.01, "MAX": 5.0 },
        { "NAME": "strength", "TYPE": "float", "LABEL": "Shadow strength",
          "DEFAULT": 0.7, "MIN": 0.0, "MAX": 1.0 }
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

    // Reconstruct world position of this fragment.
    mat4 invVP = inverse(camera.viewProjection);
    vec3 worldPos = dh_worldPosFromDepth(uv, rawD, invVP);

    // March TOWARD the light (opposite of lightDir).
    vec3 L = normalize(-lightDir);
    float stepLen = rayLength / float(stepCount);
    float jitter = dh_ign(isf_FragCoord.xy) * stepLen;

    float occluded = 0.0;
    for (int i = 1; i <= stepCount; ++i) {
        vec3 samplePos = worldPos + L * (jitter + float(i) * stepLen);
        vec4 clip = camera.viewProjection * vec4(samplePos, 1.0);
        if (clip.w <= 0.0) continue;
        vec3 ndc = clip.xyz / clip.w;
        vec2 sampleUV = ndc.xy * 0.5 + 0.5;
        if (any(lessThan(sampleUV, vec2(0.0))) || any(greaterThan(sampleUV, vec2(1.0)))) continue;

        float rayRawD  = ndc.z * 0.5 + 0.5;
        float sceneRawD = IMG_DEPTH_NORM_PIXEL_LOD0(inputImage, sampleUV);
        // Reverse-Z: closer fragments have LARGER rawD. The scene occludes
        // the ray if the scene's depth is > the ray's depth (closer) AND
        // not TOO much closer (thickness gate).
        float rayEye   = dh_linearizeDepth(rayRawD,   camera.projection);
        float sceneEye = dh_linearizeDepth(sceneRawD, camera.projection);
        if (sceneEye < rayEye && (rayEye - sceneEye) < thickness) {
            occluded = 1.0;
            break;
        }
    }

    float ao = 1.0 - occluded * strength;
    isf_FragColor = vec4(color.rgb * ao, color.a);
    gl_FragDepth = rawD;
}
