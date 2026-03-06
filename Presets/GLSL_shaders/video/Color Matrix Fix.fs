/*{
    "CREDIT": "ossia score video utilities",
    "ISFVSN": "2",
    "DESCRIPTION": "Fix color matrix mismatches between SD (BT.601) and HD (BT.709) content. Corrects the green/magenta tint that occurs when video is decoded with the wrong YCbCr matrix. Also converts between BT.709 and BT.2020 primaries. Operates on linear or gamma-encoded RGB.",
    "CATEGORIES": [
        "Color"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "conversion",
            "LABEL": "Conversion",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4, 5 ],
            "LABELS":  [
                "BT.601 → BT.709 (SD→HD fix)",
                "BT.709 → BT.601 (HD→SD fix)",
                "BT.709 → BT.2020",
                "BT.2020 → BT.709",
                "BT.601 → BT.2020",
                "BT.2020 → BT.601"
            ]
        },
        {
            "NAME": "input_is_gamma",
            "LABEL": "Input is Gamma-Encoded",
            "TYPE": "bool",
            "DEFAULT": true
        },
        {
            "NAME": "gamma_value",
            "LABEL": "Gamma (for linearize/delinearize)",
            "TYPE": "float",
            "DEFAULT": 2.2,
            "MIN": 1.0,
            "MAX": 3.0
        }
    ]
}*/

// Gamut conversion matrices (linear-light domain)
// All column-major (GLSL convention).

// BT.601 (NTSC/PAL SD) ↔ BT.709 (HD)
// These correct for the different luma/chroma definitions.
// Derived from: BT.601 RGB → XYZ → BT.709 RGB via D65 white.

const mat3 mat_601_to_709 = mat3(
     1.0440,  -0.0000,  0.0000,
    -0.0440,   1.0000,  0.0118,
     0.0000,   0.0000,  0.9882
);

const mat3 mat_709_to_601 = mat3(
     0.9578,  0.0000,  0.0000,
     0.0422,  1.0000, -0.0119,
     0.0000,  0.0000,  1.0119
);

// BT.709 ↔ BT.2020
const mat3 mat_709_to_2020 = mat3(
    0.6274, 0.0691, 0.0164,
    0.3293, 0.9195, 0.0880,
    0.0433, 0.0114, 0.8956
);

const mat3 mat_2020_to_709 = mat3(
     1.6605, -0.1246, -0.0182,
    -0.5876,  1.1329, -0.1006,
    -0.0728, -0.0083,  1.1187
);

// BT.601 ↔ BT.2020 (composed: 601→709→2020 and reverse)
const mat3 mat_601_to_2020 = mat3(
    0.6553, 0.0691, 0.0164,
    0.3103, 0.9195, 0.0872,
    0.0344, 0.0114, 0.8964
);

const mat3 mat_2020_to_601 = mat3(
     1.5918, -0.1246, -0.0181,
    -0.5126,  1.1329, -0.1026,
    -0.0792, -0.0083,  1.1207
);

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    // Linearize if needed (matrix multiply must happen in linear light)
    if (input_is_gamma) {
        c = pow(max(c, 0.0), vec3(gamma_value));
    }

    // Apply matrix
    if (conversion == 0)      c = mat_601_to_709 * c;
    else if (conversion == 1) c = mat_709_to_601 * c;
    else if (conversion == 2) c = mat_709_to_2020 * c;
    else if (conversion == 3) c = mat_2020_to_709 * c;
    else if (conversion == 4) c = mat_601_to_2020 * c;
    else if (conversion == 5) c = mat_2020_to_601 * c;

    // Re-encode gamma
    if (input_is_gamma) {
        c = pow(max(c, 0.0), vec3(1.0 / gamma_value));
    }

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
