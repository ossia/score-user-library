/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Channel mixer: redefine each output channel as a weighted combination of all input channels. Used for creative color effects, film stock emulation, advanced B&W conversion, and cross-processing looks. Works in linear or gamma space.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "red_in_red",  "LABEL": "Red ← Red",    "TYPE": "float", "DEFAULT": 1.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "red_in_green","LABEL": "Red ← Green",   "TYPE": "float", "DEFAULT": 0.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "red_in_blue", "LABEL": "Red ← Blue",    "TYPE": "float", "DEFAULT": 0.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "green_in_red",  "LABEL": "Green ← Red",  "TYPE": "float", "DEFAULT": 0.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "green_in_green","LABEL": "Green ← Green", "TYPE": "float", "DEFAULT": 1.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "green_in_blue", "LABEL": "Green ← Blue",  "TYPE": "float", "DEFAULT": 0.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "blue_in_red",  "LABEL": "Blue ← Red",    "TYPE": "float", "DEFAULT": 0.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "blue_in_green","LABEL": "Blue ← Green",   "TYPE": "float", "DEFAULT": 0.0, "MIN": -2.0, "MAX": 2.0
        },
        {
            "NAME": "blue_in_blue", "LABEL": "Blue ← Blue",    "TYPE": "float", "DEFAULT": 1.0, "MIN": -2.0, "MAX": 2.0
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

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    // Channel mix matrix
    mat3 mixer = mat3(
        red_in_red,   green_in_red,   blue_in_red,
        red_in_green, green_in_green, blue_in_green,
        red_in_blue,  green_in_blue,  blue_in_blue
    );

    vec3 mixed = mixer * c;

    // Optionally restore original luminance
    if (preserve_luminance) {
        float origL = dot(luma, c);
        float mixedL = dot(luma, mixed);
        if (mixedL > 1e-6) {
            mixed *= origL / mixedL;
        }
    }

    gl_FragColor = vec4(mixed, orig.a);
}
