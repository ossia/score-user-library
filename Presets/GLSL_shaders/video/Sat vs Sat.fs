/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Saturation vs Saturation: adjust saturation based on the input pixel's existing saturation. Low-saturation pixels can be boosted (vibrance effect) while high-saturation pixels are compressed (taming neon/clipping). Equivalent to Resolve's Sat vs Sat curve. Also functions as a professional vibrance control. Linear-pipeline safe.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "low_sat_adjust",
            "LABEL": "Low Saturation Boost",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "mid_sat_adjust",
            "LABEL": "Mid Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "high_sat_adjust",
            "LABEL": "High Saturation Compress",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "low_threshold",
            "LABEL": "Low ↔ Mid Boundary",
            "TYPE": "float",
            "DEFAULT": 0.15,
            "MIN": 0.01,
            "MAX": 0.4
        },
        {
            "NAME": "high_threshold",
            "LABEL": "Mid ↔ High Boundary",
            "TYPE": "float",
            "DEFAULT": 0.6,
            "MIN": 0.3,
            "MAX": 1.0
        },
        {
            "NAME": "vibrance_mode",
            "LABEL": "Simple Vibrance Mode",
            "TYPE": "bool",
            "DEFAULT": false
        },
        {
            "NAME": "vibrance",
            "LABEL": "Vibrance",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -1.0,
            "MAX": 1.0
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

// Compute saturation as distance from the luminance axis
// (chroma / luminance ratio, normalized)
float getSaturation(vec3 c, float L) {
    if (L < 1e-6) return 0.0;
    vec3 diff = c - L;
    return length(diff) / (L + 0.001);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    float L = dot(luma, c);

    if (vibrance_mode) {
        // Simple vibrance: boost low-saturation pixels more than high-saturation
        // saturation multiplier = 1 + vibrance * (1 - currentSaturation)
        float sat = getSaturation(c, L);
        float satNorm = clamp(sat / 1.5, 0.0, 1.0); // normalize roughly to 0-1
        float factor = 1.0 + vibrance * (1.0 - satNorm);
        factor = max(factor, 0.0);
        c = L + (c - L) * factor;
    } else {
        // Full Sat vs Sat: three zones based on input saturation level
        float sat = getSaturation(c, L);
        float satNorm = clamp(sat / 1.5, 0.0, 1.0);

        // Zone weights (same smoothstep model as Lum vs Sat)
        float wLow  = 1.0 - smoothstep(0.0, low_threshold, satNorm);
        float wHigh = smoothstep(high_threshold, 1.0, satNorm);
        float wMid  = max(1.0 - wLow - wHigh, 0.0);

        float factor = wLow * low_sat_adjust
                      + wMid * mid_sat_adjust
                      + wHigh * high_sat_adjust;

        c = L + (c - L) * factor;
    }

    gl_FragColor = vec4(c, orig.a);
}
