/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Render the reconstructed view-space normal of the scene as colour. Three modes: View (raw normal * 0.5 + 0.5, the classic 'candy' look), Absolute (|normal| * colour), and Polar (colour-wheel by azimuth, brightness by elevation).",
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
        { "NAME": "mode", "TYPE": "long", "LABEL": "Render mode",
          "VALUES": [0, 1, 2], "LABELS": ["View", "Absolute", "Polar"], "DEFAULT": 0 },
        { "NAME": "tint", "TYPE": "color", "LABEL": "Tint (multiplied with normal colour)",
          "DEFAULT": [1.0, 1.0, 1.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    if (dh_isSky(rawD)) {
        isf_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        gl_FragDepth = rawD;
        return;
    }

    vec2 texel = 1.0 / RENDERSIZE;
    float d0 = rawD;
    float dR = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2( texel.x, 0.0));
    float dL = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(-texel.x, 0.0));
    float dU = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0,  texel.y));
    float dD = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, -texel.y));
    vec3 N = dh_reconstructViewNormalImproved(uv, texel, d0, dR, dL, dU, dD, camera.projection);

    vec3 rgb;
    if (mode == 0) {
        rgb = N * 0.5 + 0.5;
    } else if (mode == 1) {
        rgb = abs(N);
    } else {
        float az = atan(N.y, N.x);                 // [-pi, pi]
        float el = asin(clamp(N.z, -1.0, 1.0));    // [-pi/2, pi/2]
        float hue = (az + DH_PI) / DH_TWO_PI;      // [0, 1]
        // HSV with S=1, V=elevation-mapped brightness.
        vec3 k = vec3(5.0, 3.0, 1.0) / 3.0;
        vec3 p = abs(fract(hue + k) * 6.0 - 3.0);
        vec3 hsv_rgb = clamp(p - 1.0, 0.0, 1.0);
        float v = 0.35 + 0.65 * (el + DH_PI * 0.5) / DH_PI;
        rgb = hsv_rgb * v;
    }
    rgb *= tint.rgb;

    isf_FragColor = vec4(rgb, 1.0);
    gl_FragDepth = rawD;
}
