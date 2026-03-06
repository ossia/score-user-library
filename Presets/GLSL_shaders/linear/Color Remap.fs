/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Color remap / gradient map. Maps pixel luminance through a color gradient for duotone, thermal camera, and creative recoloring. Mix control blends with original.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "color_shadows",
            "LABEL": "Shadows Color",
            "TYPE": "color",
            "DEFAULT": [ 0.0, 0.0, 0.2, 1.0 ]
        },
        {
            "NAME": "color_midtones",
            "LABEL": "Midtones Color",
            "TYPE": "color",
            "DEFAULT": [ 0.5, 0.2, 0.1, 1.0 ]
        },
        {
            "NAME": "color_highlights",
            "LABEL": "Highlights Color",
            "TYPE": "color",
            "DEFAULT": [ 1.0, 0.9, 0.7, 1.0 ]
        },
        {
            "NAME": "midpoint",
            "LABEL": "Midtone Position",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.1,
            "MAX": 0.9
        },
        {
            "NAME": "mix_amount",
            "LABEL": "Mix",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "preserve_luminance",
            "LABEL": "Preserve Luminance",
            "TYPE": "bool",
            "DEFAULT": false
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

// Three-point gradient interpolation
vec3 gradient(float t) {
    if (t < midpoint) {
        return mix(color_shadows.rgb, color_midtones.rgb, t / midpoint);
    } else {
        return mix(color_midtones.rgb, color_highlights.rgb, (t - midpoint) / (1.0 - midpoint));
    }
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    float L = clamp(dot(luma, c), 0.0, 1.0);
    vec3 mapped = gradient(L);

    if (preserve_luminance) {
        float mappedL = dot(luma, mapped);
        if (mappedL > 1e-6)
            mapped *= L / mappedL;
    }

    c = mix(c, mapped, mix_amount);
    gl_FragColor = vec4(c, orig.a);
}
