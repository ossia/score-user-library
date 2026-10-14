/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Fake rim light from reconstructed normals. Surfaces facing away from the camera get tinted with rimColor — the anime / toon-shade halo effect. Works on any depth-enabled scene without needing actual normal textures.",
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
        { "NAME": "rimColor", "TYPE": "color", "LABEL": "Rim colour",
          "DEFAULT": [1.0, 0.9, 0.7, 1.0] },
        { "NAME": "rimPower", "TYPE": "float", "LABEL": "Rim sharpness (higher = tighter)",
          "DEFAULT": 3.0, "MIN": 0.1, "MAX": 20.0 },
        { "NAME": "rimStrength", "TYPE": "float", "LABEL": "Rim intensity",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 5.0 }
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

    // View vector in view space looks down -Z. Rim term is 1 - |N . V|.
    // With camera-facing geometry, N.z is positive (facing +Z in our reconstruction);
    // edges where the surface turns away have N.z approaching 0.
    // Use the real view vector (towards the camera from this point), not
    // +Z: away from the screen centre a camera-facing surface has N.z < 1
    // and the N.z shortcut rim-lit every floor and wall.
    vec3 P = dh_viewPosFromDepth(uv, d0, inverse(camera.projection));
    vec3 V = normalize(-P);
    float facing = clamp(abs(dot(N, V)), 0.0, 1.0);
    float rim = pow(1.0 - facing, rimPower) * rimStrength;

    vec3 outRgb = color.rgb + rimColor.rgb * rim;

    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
