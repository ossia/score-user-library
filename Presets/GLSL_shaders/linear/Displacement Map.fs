/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Displacement map: uses a second image to warp the first. Red channel displaces horizontally, green displaces vertically. Feed noise, video, or any texture as the map.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "displaceMap", "TYPE": "image" },
        {
            "NAME": "amount",
            "LABEL": "Displacement Amount",
            "TYPE": "float",
            "DEFAULT": 0.05,
            "MIN": 0.0,
            "MAX": 0.5
        },
        {
            "NAME": "center_bias",
            "LABEL": "Map Center (0.5 = neutral)",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "channel_mode",
            "LABEL": "Channel Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "RG (red=X, green=Y)", "Luminance (both axes)", "R only (horizontal)" ]
        },
        {
            "NAME": "wrap",
            "LABEL": "Edge Wrap",
            "TYPE": "bool",
            "DEFAULT": false
        }
    ]
}*/

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec2 uv = isf_FragNormCoord;

    // Sample displacement map
    vec4 d = IMG_NORM_PIXEL(displaceMap, uv);

    vec2 offset;
    if (channel_mode == 0) {
        // RG: red = horizontal, green = vertical
        offset = (d.rg - center_bias) * amount;
    } else if (channel_mode == 1) {
        // Luminance drives both axes equally
        float L = dot(luma, d.rgb) - center_bias;
        offset = vec2(L) * amount;
    } else {
        // Red only, horizontal displacement
        offset = vec2((d.r - center_bias) * amount, 0.0);
    }

    vec2 displaced = uv + offset;

    if (wrap) {
        displaced = fract(displaced);
    }

    vec3 c = IMG_NORM_PIXEL(inputImage, displaced).rgb;
    gl_FragColor = vec4(c, IMG_NORM_PIXEL(inputImage, uv).a);
}
