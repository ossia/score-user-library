/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Radial (zoom) blur. Samples along lines radiating from a center point, simulating camera zoom or impact motion. More samples = smoother but heavier. Linear-safe: averages correctly in linear light.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "amount",
            "LABEL": "Amount",
            "TYPE": "float",
            "DEFAULT": 0.1,
            "MIN": 0.0,
            "MAX": 0.5
        },
        {
            "NAME": "center",
            "LABEL": "Center",
            "TYPE": "point2D",
            "DEFAULT": [ 0.5, 0.5 ]
        },
        {
            "NAME": "samples",
            "LABEL": "Quality (Samples)",
            "TYPE": "long",
            "DEFAULT": 1,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Low (8)", "Medium (16)", "High (32)" ]
        },
        {
            "NAME": "mode",
            "LABEL": "Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Zoom (radial out)", "Spin (rotational)", "Both" ]
        },
        {
            "NAME": "falloff",
            "LABEL": "Center Falloff",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": 0.0,
            "MAX": 1.0
        }
    ]
}*/

// Rotate a 2D vector by angle
vec2 rot2d(vec2 v, float a) {
    float c = cos(a);
    float s = sin(a);
    return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec2 dir = uv - center;
    float dist = length(dir);

    int numSamples;
    if (samples == 0) numSamples = 8;
    else if (samples == 1) numSamples = 16;
    else numSamples = 32;

    // Distance-based strength (optionally reduce near center)
    float strength = amount * mix(1.0, smoothstep(0.0, 0.3, dist), falloff);

    vec3 sum = vec3(0.0);
    float totalWeight = 0.0;

    for (int i = 0; i < 32; i++) {
        if (i >= numSamples) break;

        float t = float(i) / float(numSamples - 1) - 0.5; // [-0.5, 0.5]
        vec2 offset = vec2(0.0);

        if (mode == 0 || mode == 2) {
            // Zoom: offset along radial direction
            offset += dir * t * strength;
        }
        if (mode == 1 || mode == 2) {
            // Spin: offset perpendicular (rotate around center)
            float angle = t * strength * 3.14159;
            vec2 rotated = rot2d(dir, angle);
            offset += rotated - dir;
        }

        vec2 sampleUV = uv + offset;
        // Gaussian-ish weight (center sample stronger)
        float w = 1.0 - abs(t) * 1.5;
        w = max(w, 0.1);

        sum += IMG_NORM_PIXEL(inputImage, sampleUV).rgb * w;
        totalWeight += w;
    }

    vec3 c = sum / totalWeight;

    gl_FragColor = vec4(c, IMG_NORM_PIXEL(inputImage, uv).a);
}
