/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Underwater/pool caustics overlay. A procedural caustic network (zero-crossings of two sum-of-sines fields, evaluated on the world XZ plane so it sticks to surfaces) is modulated by depth-attenuated light reaching the fragment, creating the dappled-light effect of looking through water.",
    "CATEGORIES": ["Post-process", "Atmosphere"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true,
          "LABEL": "Scene color + depth" },

        {
            "NAME": "camera", "TYPE": "uniform",
            "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" }
            ]
        },

        { "NAME": "causticColor", "TYPE": "color",
          "LABEL": "Caustic highlight colour",
          "DEFAULT": [0.7, 0.95, 1.0, 1.0] },

        { "NAME": "causticScale", "TYPE": "float",
          "LABEL": "Caustic pattern scale",
          "DEFAULT": 8.0, "MIN": 0.5, "MAX": 60.0 },

        { "NAME": "causticSpeed", "TYPE": "float",
          "LABEL": "Caustic animation speed",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 5.0 },

        { "NAME": "causticIntensity", "TYPE": "float",
          "LABEL": "Caustic intensity",
          "DEFAULT": 0.8, "MIN": 0.0, "MAX": 3.0 },

        { "NAME": "attenuation", "TYPE": "float",
          "LABEL": "Depth attenuation (higher = caustics fade faster with distance)",
          "DEFAULT": 0.04, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "skyPassthrough", "TYPE": "bool",
          "LABEL": "Leave sky untouched",
          "DEFAULT": true }
    ]
}*/

#include "depth_helpers.glsl"

// Caustic network. Real pool caustics are the focal curves of light refracted
// by a wavy surface: thin bright filaments on a dim field. Two sum-of-sines
// height fields are summed; the filaments are where the sum crosses zero,
// shaped by a high power of (1 - |sum|) so they stay thin. (The earlier
// version returned pow(sum, 2.5) of the same field, which is a grid of soft
// round blobs rather than a network.)
float caustic(vec2 p, float t)
{
    vec2 a = p + vec2(sin(t * 0.9),       cos(t * 0.7));
    vec2 b = p + vec2(cos(t * 1.1 + 1.3), sin(t * 1.3 + 2.1));

    float va = sin(a.x * 1.2) + sin(a.y * 1.1) + sin((a.x + a.y) * 0.85 + t);
    float vb = sin(b.x * 1.3 + t * 0.8) + sin(b.y * 1.15 - t * 0.6)
             + sin((b.x - b.y) * 0.9 - t * 0.5);

    float ridgeA = pow(1.0 - clamp(abs(va) / 3.0, 0.0, 1.0), 8.0);
    float ridgeB = pow(1.0 - clamp(abs(vb) / 3.0, 0.0, 1.0), 8.0);
    return clamp(ridgeA + ridgeB, 0.0, 1.0);
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    if (skyPassthrough && dh_isSky(rawD)) {
        isf_FragColor = color;
        gl_FragDepth = rawD;
        return;
    }

    float eye = dh_linearizeDepth(rawD, camera.projection);

    // Sample the pattern in WORLD space, on the horizontal plane (light
    // from a water surface above falls roughly vertically), so it sticks to
    // the geometry when the camera moves instead of swimming on the screen.
    // causticScale is then "pattern cells per 2*pi metres".
    vec3 world = dh_worldPosFromDepth(uv, rawD, inverse(camera.viewProjection));
    float c = caustic(world.xz * causticScale, TIME * causticSpeed);

    // Beer–Lambert depth attenuation: light that reaches this surface has
    // travelled through `eye` metres of water.
    float transmit = exp(-attenuation * eye);

    float add = c * causticIntensity * transmit;
    vec3 outRgb = color.rgb + causticColor.rgb * add;

    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
