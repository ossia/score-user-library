/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "False-colour depth visualisation. Quantises view-space eye depth into bands and maps each band through a built-in palette (Thermal, Viridis, Magma, or Rainbow). The scene can be replaced entirely with the false-colour, or blended with the original for a heatmap-overlay look. The false colour is painted over the input at the Mix amount, so pixels with no geometry get the Sky colour even where the input is transparent.",
    "CATEGORIES": ["Post-process", "Atmosphere"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true,
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

        { "NAME": "paletteMode", "TYPE": "long",
          "LABEL": "Palette",
          "VALUES": [0, 1, 2, 3],
          "LABELS": ["Thermal", "Viridis", "Magma", "Rainbow"],
          "DEFAULT": 0 },

        { "NAME": "bandCount", "TYPE": "long",
          "LABEL": "Depth bands",
          "VALUES": [4, 8, 16, 32, 64, 128],
          "LABELS": ["4", "8", "16", "32", "64", "128"],
          "DEFAULT": 16 },

        { "NAME": "cutoffDepth", "TYPE": "float",
          "LABEL": "Far cutoff (world units, maps to palette end)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },

        { "NAME": "mixAmount", "TYPE": "float",
          "LABEL": "Mix (0 = scene, 1 = false-colour)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "skyColor", "TYPE": "color",
          "LABEL": "Sky colour (for pixels with no geometry)",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

// Built-in palettes. Each is a 4-stop gradient in linear RGB, sampled by t
// in [0, 1]. t == 0 is "near" (closest to the camera), t == 1 is "far".

vec3 palette_thermal(float t)
{
    // Black → dark purple → red → yellow.
    vec3 c0 = vec3(0.0, 0.0, 0.0);
    vec3 c1 = vec3(0.1, 0.0, 0.4);
    vec3 c2 = vec3(0.8, 0.1, 0.2);
    vec3 c3 = vec3(1.0, 0.9, 0.2);
    float s = clamp(t, 0.0, 1.0) * 3.0;
    if (s < 1.0)      return mix(c0, c1, s);
    else if (s < 2.0) return mix(c1, c2, s - 1.0);
    else              return mix(c2, c3, s - 2.0);
}

vec3 palette_viridis(float t)
{
    // Approximation of the viridis LUT using polynomial fit (Nathan Boyer / bhushan-m).
    t = clamp(t, 0.0, 1.0);
    vec3 c = vec3(0.2777273272234177, 0.005407344544966578, 0.3340998053353061);
    c += t * vec3(0.1050930431085774,  1.404613529898575,    1.384590162594685);
    c += t*t * vec3(-0.3308618287255563, 0.214847559468213, 0.09509516302823659);
    c += t*t*t * vec3(-4.634230498983486, -5.799100973351585, -19.33244095627987);
    c += t*t*t*t * vec3(6.228269936347081,  14.17993336680509,  56.69055260068105);
    c += t*t*t*t*t * vec3(4.776384997670288, -13.74514537774601, -65.35303263337234);
    c += t*t*t*t*t*t * vec3(-5.435455855934631, 4.645852612178535, 26.3124352495832);
    return clamp(c, 0.0, 1.0);
}

vec3 palette_magma(float t)
{
    t = clamp(t, 0.0, 1.0);
    vec3 c = vec3(-0.002136485053939582, -0.000749655052795221, -0.005386127855323933);
    c += t * vec3(0.2516605407371642, 0.6775232436837668, 2.494026599312351);
    c += t*t * vec3(8.353717279216625, -3.577719514958284, 0.3144679030132573);
    c += t*t*t * vec3(-27.66873308576866, 14.26473078096533, -13.64921318813922);
    c += t*t*t*t * vec3(52.17613981234068, -27.94360607168351, 12.94416944238394);
    c += t*t*t*t*t * vec3(-50.76852536473588, 29.04658282127291, 4.23415299384598);
    c += t*t*t*t*t*t * vec3(18.65621068147057, -11.48977351997711, -5.601961508734096);
    return clamp(c, 0.0, 1.0);
}

vec3 palette_rainbow(float t)
{
    // Classic rainbow: red → yellow → green → cyan → blue → magenta.
    t = clamp(t, 0.0, 1.0);
    float h = t * 5.0;
    float r = clamp(min(h, 5.0 - h) * 0.5, 0.0, 1.0);
    float g = clamp(min(h, 4.0 - h), 0.0, 1.0);
    float b = clamp(min(h - 2.0, 5.0 - h), 0.0, 1.0);
    return vec3(r, g, b);
}

vec3 samplePalette(int mode, float t)
{
    if      (mode == 0) return palette_thermal(t);
    else if (mode == 1) return palette_viridis(t);
    else if (mode == 2) return palette_magma(t);
    else                return palette_rainbow(t);
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec3 falseColour;
    if (dh_isSky(rawD))
    {
        falseColour = skyColor.rgb;
    }
    else
    {
        float eye   = dh_linearizeDepth(rawD, camera.projection);
        float t     = clamp(eye / cutoffDepth, 0.0, 1.0);
        float banded = dh_quantize(t, float(bandCount));

        falseColour = samplePalette(paletteMode, banded);
    }

    // The cleared sky has alpha 0: keep what this shader paints over it visible.
    isf_FragColor = dh_paintOver(color, falseColour, mixAmount);
    gl_FragDepth = rawD;
}
