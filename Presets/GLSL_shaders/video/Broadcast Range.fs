/*{
    "CREDIT": "ossia score video utilities",
    "ISFVSN": "2",
    "DESCRIPTION": "Convert between broadcast limited range (16-235) and full range (0-255). Fixes washed-out blacks or crushed highlights from range mismatches. Also handles super-whites (235-255) used in some broadcast content.",
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
            "VALUES":  [ 0, 1, 2, 3 ],
            "LABELS":  [
                "Limited to Full (expand)",
                "Full to Limited (compress)",
                "Limited to Full (10-bit)",
                "Full to Limited (10-bit)"
            ]
        },
        {
            "NAME": "preserve_superwhite",
            "LABEL": "Preserve Super-Whites",
            "TYPE": "bool",
            "DEFAULT": false
        }
    ]
}*/

// 8-bit limited range: Y [16,235], C [16,240]
// For RGB (post-matrix): [16,235] maps to [0,255]
// 10-bit limited range: [64,940] maps to [0,1023]

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    if (conversion == 0) {
        // 8-bit limited to full: (v - 16/255) * 255/219
        c = (c - 16.0 / 255.0) * (255.0 / 219.0);
    }
    else if (conversion == 1) {
        // 8-bit full to limited: v * 219/255 + 16/255
        c = c * (219.0 / 255.0) + 16.0 / 255.0;
    }
    else if (conversion == 2) {
        // 10-bit limited to full: (v - 64/1023) * 1023/876
        c = (c - 64.0 / 1023.0) * (1023.0 / 876.0);
    }
    else if (conversion == 3) {
        // 10-bit full to limited: v * 876/1023 + 64/1023
        c = c * (876.0 / 1023.0) + 64.0 / 1023.0;
    }

    if (!preserve_superwhite) {
        c = clamp(c, 0.0, 1.0);
    }

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
