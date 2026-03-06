/*{
    "CREDIT": "ossia score HDR pipeline",
    "ISFVSN": "2",
    "DESCRIPTION": "Color gamut conversion between BT.709 (sRGB) and BT.2020 primaries. Operates on linear-light input. Place after EOTF and before OETF in the chain.",
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
            "VALUES":  [ 0, 1 ],
            "LABELS":  [ "BT.2020 → BT.709", "BT.709 → BT.2020" ]
        },
        {
            "NAME": "gamut_clip",
            "LABEL": "Clip Out-of-Gamut",
            "TYPE": "bool",
            "DEFAULT": false
        }
    ]
}*/

const mat3 mat_bt2020_to_bt709 = mat3(
     1.6605, -0.1246, -0.0182,
    -0.5876,  1.1329, -0.1006,
    -0.0728, -0.0083,  1.1187
);

const mat3 mat_bt709_to_bt2020 = mat3(
    0.6274, 0.0691, 0.0164,
    0.3293, 0.9195, 0.0880,
    0.0433, 0.0114, 0.8956
);

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    if (conversion == 0)
        c = mat_bt2020_to_bt709 * c;
    else
        c = mat_bt709_to_bt2020 * c;

    if (gamut_clip) c = clamp(c, 0.0, 1.0);

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
