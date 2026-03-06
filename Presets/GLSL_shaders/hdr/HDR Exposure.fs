/*{
    "CREDIT": "ossia score HDR pipeline",
    "ISFVSN": "2",
    "DESCRIPTION": "HDR exposure and normalization controls. Use to scale between absolute luminance (nits from PQ decode) and normalized working space (1.0 = SDR white), or to adjust exposure in EV stops.",
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
            "LABEL": "Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2 ],
            "LABELS":  [
                "Nits → Normalized (÷ SDR peak)",
                "Normalized → Nits (× SDR peak)",
                "EV Exposure Only"
            ]
        },
        {
            "NAME": "sdr_white_nits",
            "LABEL": "SDR Reference White (nits)",
            "TYPE": "float",
            "DEFAULT": 203.0,
            "MIN": 80.0,
            "MAX": 400.0
        },
        {
            "NAME": "exposure_ev",
            "LABEL": "Exposure (EV)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -6.0,
            "MAX": 6.0
        }
    ]
}*/

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    if (mode == 0) {
        // Nits → normalized: 203 nits becomes 1.0
        c /= sdr_white_nits;
    } else if (mode == 1) {
        // Normalized → nits: 1.0 becomes 203 nits
        c *= sdr_white_nits;
    }

    // Exposure always applies
    c *= pow(2.0, exposure_ev);

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
