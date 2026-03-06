/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Haze removal / dehaze based on the dark channel prior (He et al. 2009). Estimates atmospheric light and scene transmission from the darkest channel in local neighborhoods, then recovers clear scene radiance. Negative strength adds haze (fog effect). Based on darktable's haze removal approach, adapted for single-pass real-time use. Works on linear or gamma-encoded images.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "strength",
            "LABEL": "Dehaze Strength",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": -1.0,
            "MAX": 1.0
        },
        {
            "NAME": "atmospheric_light",
            "LABEL": "Atmospheric Light",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.5,
            "MAX": 2.0
        },
        {
            "NAME": "kernel_size",
            "LABEL": "Kernel Size",
            "TYPE": "float",
            "DEFAULT": 5.0,
            "MIN": 1.0,
            "MAX": 15.0
        },
        {
            "NAME": "min_transmission",
            "LABEL": "Min Transmission",
            "TYPE": "float",
            "DEFAULT": 0.1,
            "MIN": 0.01,
            "MAX": 0.5
        },
        {
            "NAME": "saturation_boost",
            "LABEL": "Saturation Recovery",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": 0.0,
            "MAX": 0.5
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

// Dark channel: minimum of RGB in a local neighborhood
// Full dark channel prior uses a large window (e.g. 15x15),
// but for real-time we use a compact 3x3 or 5x5 cross pattern
// sampled at the configured kernel_size spacing.
float darkChannel(vec2 uv) {
    vec2 px = kernel_size / RENDERSIZE;

    // 9-point sampling pattern (3x3 grid at kernel spacing)
    float dc = 1e10;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 off = vec2(float(x), float(y)) * px;
            vec3 s = IMG_NORM_PIXEL(inputImage, uv + off).rgb;
            float minRGB = min(s.r, min(s.g, s.b));
            dc = min(dc, minRGB);
        }
    }
    return dc;
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    if (abs(strength) < 0.01) {
        gl_FragColor = orig;
        return;
    }

    // Atmospheric light estimate (A)
    // In the full algorithm this is extracted from the brightest pixels
    // in the dark channel. Here we use the user parameter, defaulting
    // to 1.0 (white atmospheric light, standard for most scenes).
    float A = atmospheric_light;

    // Compute dark channel normalized by atmospheric light
    float dc = darkChannel(uv) / A;

    // Transmission estimate: t(x) = 1 - strength * dark_channel(x)/A
    // strength controls how much haze to remove (negative adds haze)
    float t = 1.0 - abs(strength) * dc;

    // Clamp transmission to avoid division by near-zero
    t = max(t, min_transmission);

    if (strength > 0.0) {
        // DEHAZE: recover scene radiance
        // J(x) = (I(x) - A) / max(t, t_min) + A
        // Rearranged: J = (I - A*(1-t)) / t
        vec3 dehazed = (c - A * (1.0 - t)) / t;

        // Optional saturation recovery: dehazing can desaturate
        if (saturation_boost > 0.0) {
            float L = dot(luma, dehazed);
            if (L > 1e-6) {
                dehazed = L + (dehazed - L) * (1.0 + saturation_boost);
            }
        }

        c = dehazed;
    } else {
        // ADD HAZE (fog effect): I_hazy = I * t + A * (1 - t)
        float fogT = t; // t already computed with abs(strength)
        c = c * fogT + A * (1.0 - fogT);
    }

    gl_FragColor = vec4(c, orig.a);
}
