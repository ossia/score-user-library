/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Photographic film grain. Organic noise weighted by luminance (more visible in midtones, less in deep shadows and bright highlights, like real film). Configurable size, intensity, and color/mono balance.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "intensity",
            "LABEL": "Intensity",
            "TYPE": "float",
            "DEFAULT": 0.05,
            "MIN": 0.0,
            "MAX": 0.3
        },
        {
            "NAME": "size",
            "LABEL": "Grain Size",
            "TYPE": "float",
            "DEFAULT": 1.5,
            "MIN": 0.5,
            "MAX": 4.0
        },
        {
            "NAME": "color_amount",
            "LABEL": "Color Grain",
            "TYPE": "float",
            "DEFAULT": 0.3,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "midtone_bias",
            "LABEL": "Midtone Bias",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 1.0
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

// Hash-based pseudo-random (repeatable per pixel per frame)
float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float hash13(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.zyx + 31.32);
    return fract((p.x + p.y) * p.z);
}

// Approximate Gaussian from uniform hash (Box-Muller simplified)
float gaussianNoise(vec2 uv, float seed) {
    float u1 = max(hash13(vec3(uv, seed)), 1e-6);
    float u2 = hash13(vec3(uv, seed + 17.37));
    return sqrt(-2.0 * log(u1)) * cos(6.2831853 * u2);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    // Grain coordinate (quantized for size control)
    vec2 grainUV = floor(gl_FragCoord.xy / size) * size;
    float t = TIME * 60.0; // animate grain per frame

    // Luminance noise (monochrome grain)
    float monoGrain = gaussianNoise(grainUV, t);

    // Color noise (per-channel, shifted seeds)
    vec3 colorGrain = vec3(
        gaussianNoise(grainUV, t + 1.0),
        gaussianNoise(grainUV, t + 2.0),
        gaussianNoise(grainUV, t + 3.0)
    );

    // Blend mono and color grain
    vec3 grain = mix(vec3(monoGrain), colorGrain, color_amount);

    // Luminance-weighted response: more grain in midtones
    // f(L) = L * (1-L) * 4 peaks at L=0.5
    float L = dot(luma, c);
    float weight = mix(1.0, 4.0 * L * (1.0 - clamp(L, 0.0, 1.0)), midtone_bias);

    c += grain * intensity * weight;

    gl_FragColor = vec4(c, orig.a);
}
