/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Solarize: inverts tones above a threshold, simulating the Sabattier darkroom effect. Classic VJ and photographic effect. Smooth mode creates a psychedelic color wave. Invert mode operates on luminance to preserve hue.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "mode",
            "LABEL": "Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Classic (per-channel)", "Luminance-based", "Smooth Wave" ]
        },
        {
            "NAME": "threshold_val",
            "LABEL": "Threshold",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 2.0
        },
        {
            "NAME": "mix_amount",
            "LABEL": "Mix",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 1.0
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;
    vec3 result;

    if (mode == 0) {
        // Classic: invert each channel above threshold independently
        result = mix(c, 2.0 * threshold_val - c, step(vec3(threshold_val), c));
    }
    else if (mode == 1) {
        // Luminance-based: invert RGB proportionally when luma > threshold
        float L = dot(luma, c);
        if (L > threshold_val) {
            float invL = 2.0 * threshold_val - L;
            result = c * (invL / max(L, 1e-6));
        } else {
            result = c;
        }
    }
    else {
        // Smooth wave: sine-based curve creates psychedelic multi-inversion
        float freq = 3.14159265 / threshold_val;
        result = abs(sin(c * freq));
    }

    gl_FragColor = vec4(mix(c, result, mix_amount), orig.a);
}
