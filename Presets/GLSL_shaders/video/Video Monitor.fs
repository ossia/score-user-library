/*{
    "CREDIT": "ossia score video utilities",
    "ISFVSN": "2",
    "DESCRIPTION": "Video monitoring tools: false-color exposure map, zebra stripes for clipping, and luminance waveform overlay. Essential for checking levels in SDR and HDR workflows.",
    "CATEGORIES": [
        "Color"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "mode",
            "LABEL": "Display Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4 ],
            "LABELS":  [
                "Passthrough",
                "False Color (exposure)",
                "Zebra (clipping)",
                "Luminance Only",
                "Out-of-Gamut Highlight"
            ]
        },
        {
            "NAME": "zebra_high",
            "LABEL": "Zebra High Threshold",
            "TYPE": "float",
            "DEFAULT": 0.95,
            "MIN": 0.5,
            "MAX": 1.5
        },
        {
            "NAME": "zebra_low",
            "LABEL": "Zebra Low Threshold",
            "TYPE": "float",
            "DEFAULT": 0.02,
            "MIN": 0.0,
            "MAX": 0.1
        },
        {
            "NAME": "luma_standard",
            "LABEL": "Luma Coefficients",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1 ],
            "LABELS":  [ "BT.709", "BT.2020" ]
        },
        {
            "NAME": "blend",
            "LABEL": "Overlay Blend",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 1.0
        }
    ]
}*/

const vec3 luma_709  = vec3(0.2126, 0.7152, 0.0722);
const vec3 luma_2020 = vec3(0.2627, 0.6780, 0.0593);

// False-color palette: maps luminance to diagnostic colors
// Based on ARRI false-color conventions
vec3 false_color(float L) {
    if (L < 0.005) return vec3(0.0, 0.0, 0.4);        // near-black: dark blue
    if (L < 0.02)  return vec3(0.0, 0.0, 0.8);         // deep shadow: blue
    if (L < 0.06)  return vec3(0.0, 0.4, 0.8);          // shadow: cyan-blue
    if (L < 0.12)  return vec3(0.0, 0.6, 0.3);          // shadow detail: teal
    if (L < 0.18)  return vec3(0.2, 0.2, 0.2);          // dark midtone: dark gray
    if (L < 0.25)  return vec3(0.4, 0.4, 0.4);          // mid gray (18%): gray
    if (L < 0.40)  return vec3(0.3, 0.6, 0.1);          // light midtone: green
    if (L < 0.55)  return vec3(0.5, 0.8, 0.2);          // upper mid: yellow-green
    if (L < 0.70)  return vec3(0.8, 0.8, 0.0);          // highlight: yellow
    if (L < 0.85)  return vec3(1.0, 0.5, 0.0);          // bright highlight: orange
    if (L < 0.95)  return vec3(1.0, 0.2, 0.2);          // near-clip: red
    if (L < 1.005) return vec3(1.0, 0.0, 0.5);          // clip boundary: hot pink
    return vec3(1.0, 0.0, 1.0);                          // super-white/HDR: magenta
}

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;
    vec3 lumaCoeff = (luma_standard == 0) ? luma_709 : luma_2020;
    float L = dot(lumaCoeff, c);

    if (mode == 0) {
        // Passthrough
        gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
        return;
    }

    if (mode == 1) {
        // False color exposure map
        vec3 fc = false_color(L);
        gl_FragColor = vec4(mix(c, fc, blend), IMG_THIS_PIXEL(inputImage).a);
        return;
    }

    if (mode == 2) {
        // Zebra stripes for clipping
        vec3 result = c;
        float maxC = max(c.r, max(c.g, c.b));
        float minC = min(c.r, min(c.g, c.b));

        // Diagonal stripe pattern
        float coord = gl_FragCoord.x + gl_FragCoord.y;
        float stripe = step(0.5, fract(coord / 8.0));

        // High clip zebra (red stripes)
        if (maxC > zebra_high) {
            result = mix(result, vec3(1.0, 0.0, 0.0), stripe * blend);
        }
        // Low clip zebra (blue stripes)
        if (maxC < zebra_low) {
            result = mix(result, vec3(0.0, 0.0, 1.0), stripe * blend);
        }

        gl_FragColor = vec4(result, IMG_THIS_PIXEL(inputImage).a);
        return;
    }

    if (mode == 3) {
        // Luminance only (grayscale)
        gl_FragColor = vec4(vec3(L), IMG_THIS_PIXEL(inputImage).a);
        return;
    }

    if (mode == 4) {
        // Out-of-gamut highlight
        // Show pixels where any channel is negative or > 1.0
        vec3 result = c;
        bool outOfGamut = any(lessThan(c, vec3(0.0))) || any(greaterThan(c, vec3(1.0)));

        if (outOfGamut) {
            float coord = gl_FragCoord.x + gl_FragCoord.y;
            float stripe = step(0.5, fract(coord / 6.0));

            // Negative values: cyan overlay
            if (any(lessThan(c, vec3(0.0)))) {
                result = mix(clamp(result, 0.0, 1.0), vec3(0.0, 1.0, 1.0), stripe * blend);
            }
            // Over-1 values: magenta overlay
            else {
                result = mix(clamp(result, 0.0, 1.0), vec3(1.0, 0.0, 1.0), stripe * blend);
            }
        }

        gl_FragColor = vec4(clamp(result, 0.0, 1.0), IMG_THIS_PIXEL(inputImage).a);
        return;
    }
}
