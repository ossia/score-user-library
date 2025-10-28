/*{
    "DESCRIPTION": "Converts a specific color (keyColor) to transparency. Useful for chroma keying.",
    "CATEGORIES": [
        "Filter",
        "Keying"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "keyColor",
            "TYPE": "color",
            "DEFAULT": [0.0, 1.0, 0.0, 1.0],
            "LABEL": "Key Color"
        },
        {
            "NAME": "threshold",
            "TYPE": "float",
            "DEFAULT": 0.4,
            "MIN": 0.0,
            "MAX": 1.732,
            "LABEL": "Threshold"
        },
        {
            "NAME": "smoothing",
            "TYPE": "float",
            "DEFAULT": 0.1,
            "MIN": 0.0,
            "MAX": 1.0,
            "LABEL": "Smoothing"
        }
    ]
}*/

void main() {
    // 1. Get the pixel color from the input image
    vec4 tex = IMG_PIXEL(inputImage, gl_FragCoord.xy);

    // 2. Calculate the "distance" between the pixel's color and the keyColor.
    // We use the 'distance' function which calculates the Euclidean distance in 3D (RGB) space.
    float dist = distance(tex.rgb, keyColor.rgb);

    // 3. Use smoothstep to create a smooth alpha mask.
    // - If dist is less than 'threshold', alpha will be 0.0 (fully transparent).
    // - If dist is greater than 'threshold + smoothing', alpha will be 1.0 (fully opaque).
    // - If dist is between these two values, alpha will be smoothly interpolated.
    float alpha = smoothstep(threshold, threshold + smoothing, dist);

    // 4. Set the final pixel color.
    // We use the original pixel's RGB values, but we multiply its original alpha
    // by our newly calculated keying alpha.
    gl_FragColor = vec4(tex.rgb, tex.a * alpha);
}