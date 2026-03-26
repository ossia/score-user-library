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
            "VALUES":  [ 0, 1, 2, 3, 4, 5 ],
            "LABELS":  [
                "BT.2020 to BT.709",
                "BT.709 to BT.2020",
                "BT.2020 to Display P3",
                "Display P3 to BT.2020",
                "Display P3 to BT.709",
                "BT.709 to Display P3"
            ]
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

const mat3 mat_bt2020_to_p3 = mat3(
     1.343578252584332, -0.065297452789119,  0.002821787261701,
    -0.282179670526136,  1.075787915848574, -0.019598494524494,
    -0.061398582058196, -0.010490463059455,  1.016776707262793
);

const mat3 mat_p3_to_bt2020 = mat3(
    0.753833034361722,  0.045743848965358, -0.001210340354518,
    0.198597369052617,  0.941777219811693,  0.017601717301090,
    0.047569596585662,  0.012478931222948,  0.983608623053428
);

const mat3 mat_p3_to_bt709 = mat3(
     1.224940176280561, -0.042056954709688, -0.019637554590334,
    -0.224940176280560,  1.042056954709688, -0.078636045550632,
     0.000000000000000,  0.000000000000000,  1.098273600140966
);

const mat3 mat_bt709_to_p3 = mat3(
    0.822461968714362,  0.033194198850962,  0.017082630721120,
    0.177538031285638,  0.966805801149038,  0.072397440663963,
    0.000000000000000,  0.000000000000000,  0.910519928614917
);

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    if (conversion == 0)      c = mat_bt2020_to_bt709 * c;
    else if (conversion == 1) c = mat_bt709_to_bt2020 * c;
    else if (conversion == 2) c = mat_bt2020_to_p3 * c;
    else if (conversion == 3) c = mat_p3_to_bt2020 * c;
    else if (conversion == 4) c = mat_p3_to_bt709 * c;
    else if (conversion == 5) c = mat_bt709_to_p3 * c;

    if (gamut_clip) c = clamp(c, 0.0, 1.0);

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
