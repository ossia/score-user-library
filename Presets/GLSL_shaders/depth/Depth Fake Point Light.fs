/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Fake point light: reconstructs world-space position from depth and adds a distance-attenuated light from a user-placed 3D position. Lambertian shading against the reconstructed normal. Move the light around with the `lightPos` control for a noir flashlight / torch effect.",
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
        { "NAME": "lightPos", "TYPE": "point3D", "LABEL": "Light position (world units)",
          "DEFAULT": [0.0, 3.0, 0.0] },
        { "NAME": "lightColor", "TYPE": "color", "LABEL": "Light colour",
          "DEFAULT": [1.0, 0.95, 0.8, 1.0] },
        { "NAME": "lightIntensity", "TYPE": "float", "LABEL": "Light intensity",
          "DEFAULT": 8.0, "MIN": 0.0, "MAX": 100.0 },
        { "NAME": "falloff", "TYPE": "float", "LABEL": "Falloff exponent (2 = physical, lower = softer)",
          "DEFAULT": 2.0, "MIN": 0.1, "MAX": 5.0 }
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

    // Reconstruct world position via inverse view-projection.
    mat4 invVP = inverse(camera.viewProjection);
    vec3 worldPos = dh_worldPosFromDepth(uv, rawD, invVP);

    // Reconstruct normal in view space, then transform to world.
    vec2 texel = 1.0 / RENDERSIZE;
    float d0 = rawD;
    float dR = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2( texel.x, 0.0));
    float dL = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(-texel.x, 0.0));
    float dU = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0,  texel.y));
    float dD = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, -texel.y));
    vec3 Nview = dh_reconstructViewNormalImproved(uv, texel, d0, dR, dL, dU, dD, camera.projection);

    mat4 invView = inverse(camera.view);
    vec3 Nworld = normalize((invView * vec4(Nview, 0.0)).xyz);

    vec3 L = lightPos - worldPos;
    float dist = length(L);
    vec3 Lhat = L / max(dist, 0.0001);
    float lambert = max(dot(Nworld, Lhat), 0.0);
    float atten = lightIntensity / (1.0 + pow(dist, falloff));

    vec3 lit = color.rgb + lightColor.rgb * lambert * atten;

    isf_FragColor = vec4(lit, color.a);
    gl_FragDepth = rawD;
}
