/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Fast single-pass ambient occlusion. Samples eight neighbours at a user radius, counts how many rise more than `bias` above the tangent plane of the current pixel (normal-oriented hemisphere, with a range check), and darkens proportionally. Not as clean as GTAO (see the Multi-pass wave) but cheap, punchy, and single-pass.",
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
        { "NAME": "radius", "TYPE": "float", "LABEL": "AO radius (pixels)",
          "DEFAULT": 8.0, "MIN": 1.0, "MAX": 40.0 },
        { "NAME": "bias", "TYPE": "float", "LABEL": "Height above the tangent plane (world units)",
          "DEFAULT": 0.01, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "intensity", "TYPE": "float", "LABEL": "Occlusion strength",
          "DEFAULT": 1.2, "MIN": 0.0, "MAX": 4.0 }
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

    float eye0 = dh_linearizeDepth(rawD, camera.projection);
    vec2 texel = 1.0 / RENDERSIZE;
    mat4 invP = inverse(camera.projection);
    vec3 P0 = dh_viewPosFromDepth(uv, rawD, invP);

    // Tangent plane at this pixel. Counting "nearer" samples in a flat 2D
    // disc (the first Crytek SSAO) makes every slanted plane occlude itself:
    // a floor seen at an angle has its lower taps nearer than the centre, so
    // the whole floor went grey. A sample only occludes if it rises above
    // the tangent plane by more than `bias` -- the normal-oriented hemisphere
    // test of later SSAO (e.g. McGuire et al., "The Alchemy screen-space
    // ambient obscurance algorithm", HPG 2011).
    vec3 N = dh_reconstructViewNormalImproved(uv, texel, rawD,
        IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2( texel.x, 0.0)),
        IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(-texel.x, 0.0)),
        IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0,  texel.y)),
        IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, -texel.y)),
        camera.projection);

    // The sampling radius in world units at this depth: `radius` pixels
    // times the size of one pixel at eye0 (2 * eye * tan(fov/2) / height,
    // and projection[1][1] = 1 / tan(fov/2)).
    float radiusWorld = radius * 2.0 * eye0 / (camera.projection[1][1] * RENDERSIZE.y);
    float occ = 0.0;
    const int NS = 8;
    // Jittered sample angles per fragment so the 8 taps don't line up in
    // screen space.
    float rot = dh_ign(isf_FragCoord.xy) * DH_TWO_PI;
    for (int i = 0; i < NS; ++i) {
        float a = rot + DH_TWO_PI * float(i) / float(NS);
        vec2 sUV = uv + vec2(cos(a), sin(a)) * radius * texel;
        float dS = IMG_DEPTH_NORM_PIXEL_LOD0(inputImage, sUV);
        if (dS < DH_EPSILON) continue;  // skip sky
        vec3 v = dh_viewPosFromDepth(sUV, dS, invP) - P0;
        float dist = length(v);
        // Range check (J. Chapman, "SSAO tutorial", 2013; LearnOpenGL
        // "SSAO"): an occluder much farther away than the sampling radius
        // is a different object in front, not something that occludes this
        // point. Without it every pixel next to a silhouette got a halo.
        if (dot(v, N) > bias) occ += smoothstep(0.0, 1.0, 2.0 * radiusWorld / max(dist, DH_EPSILON));
    }
    float ao = 1.0 - (occ / float(NS)) * intensity;
    ao = clamp(ao, 0.0, 1.0);

    isf_FragColor = vec4(color.rgb * ao, color.a);
    gl_FragDepth = rawD;
}
