/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Vignette with optical falloff simulation. Darkens edges naturally like a real lens. Aspect-ratio aware, with customizable shape, softness, and tint color.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "amount",
            "LABEL": "Amount",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 2.0
        },
        {
            "NAME": "softness",
            "LABEL": "Softness",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.01,
            "MAX": 2.0
        },
        {
            "NAME": "roundness",
            "LABEL": "Roundness",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "center",
            "LABEL": "Center",
            "TYPE": "point2D",
            "DEFAULT": [ 0.5, 0.5 ]
        },
        {
            "NAME": "color",
            "LABEL": "Vignette Color",
            "TYPE": "color",
            "DEFAULT": [ 0.0, 0.0, 0.0, 1.0 ]
        }
    ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 c = IMG_NORM_PIXEL(inputImage, uv);

    // Aspect-ratio-corrected distance from center
    vec2 d = uv - center;
    float aspect = RENDERSIZE.x / RENDERSIZE.y;

    // Interpolate between circular (roundness=1) and rectangular (roundness=0)
    float distCircle = length(d * vec2(aspect, 1.0));
    float distRect = max(abs(d.x) * aspect, abs(d.y));
    float dist = mix(distRect, distCircle, roundness);

    // Smooth vignette falloff
    float vig = 1.0 - smoothstep(1.0 - softness, 1.0 + softness * 0.5, dist * (1.0 + amount));

    // Multiplicative blend toward vignette color
    c.rgb = mix(color.rgb, c.rgb, vig);

    gl_FragColor = c;
}
