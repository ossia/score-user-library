/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Chromatic aberration / RGB split. Separates color channels with spatial offset. Radial mode simulates lens fringing; directional mode is a VJ staple. Works on any value range.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "mode",
            "LABEL": "Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1 ],
            "LABELS": [ "Radial (lens-like)", "Directional" ]
        },
        {
            "NAME": "amount",
            "LABEL": "Amount",
            "TYPE": "float",
            "DEFAULT": 0.005,
            "MIN": 0.0,
            "MAX": 0.05
        },
        {
            "NAME": "angle",
            "LABEL": "Direction Angle",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": 0.0,
            "MAX": 6.283
        },
        {
            "NAME": "center",
            "LABEL": "Radial Center",
            "TYPE": "point2D",
            "DEFAULT": [ 0.5, 0.5 ]
        }
    ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;

    vec2 offset;
    if (mode == 0) {
        // Radial: offset direction is away from center
        offset = (uv - center) * amount;
    } else {
        // Directional: fixed angle
        offset = vec2(cos(angle), sin(angle)) * amount;
    }

    // Red shifts outward, blue shifts inward, green stays
    float r = IMG_NORM_PIXEL(inputImage, uv + offset).r;
    float g = IMG_NORM_PIXEL(inputImage, uv).g;
    float b = IMG_NORM_PIXEL(inputImage, uv - offset).b;
    float a = IMG_NORM_PIXEL(inputImage, uv).a;

    gl_FragColor = vec4(r, g, b, a);
}
