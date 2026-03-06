/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "HSL color adjustment. Global hue shift, saturation, and luminance, plus targeted adjustment of specific hue ranges (reds, yellows, greens, cyans, blues, magentas). Staple color corrector.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "hue_shift",
            "LABEL": "Hue Shift",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -180.0,
            "MAX": 180.0
        },
        {
            "NAME": "saturation",
            "LABEL": "Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "luminance",
            "LABEL": "Luminance",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "red_hue",
            "LABEL": "Red Hue Shift",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -30.0,
            "MAX": 30.0
        },
        {
            "NAME": "red_sat",
            "LABEL": "Red Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "green_hue",
            "LABEL": "Green Hue Shift",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -30.0,
            "MAX": 30.0
        },
        {
            "NAME": "green_sat",
            "LABEL": "Green Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "blue_hue",
            "LABEL": "Blue Hue Shift",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -30.0,
            "MAX": 30.0
        },
        {
            "NAME": "blue_sat",
            "LABEL": "Blue Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        }
    ]
}*/

// RGB → HSL
vec3 rgb2hsl(vec3 c) {
    float maxC = max(c.r, max(c.g, c.b));
    float minC = min(c.r, min(c.g, c.b));
    float d = maxC - minC;
    float L = (maxC + minC) * 0.5;
    float S = 0.0;
    float H = 0.0;

    if (d > 1e-6) {
        S = (L > 0.5) ? d / (2.0 - maxC - minC) : d / (maxC + minC);
        if (maxC == c.r)      H = mod((c.g - c.b) / d, 6.0);
        else if (maxC == c.g) H = (c.b - c.r) / d + 2.0;
        else                   H = (c.r - c.g) / d + 4.0;
        H *= 60.0;
        if (H < 0.0) H += 360.0;
    }
    return vec3(H, S, L);
}

// HSL → RGB
float hue2rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0/2.0) return q;
    if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

vec3 hsl2rgb(vec3 hsl) {
    float H = hsl.x / 360.0;
    float S = hsl.y;
    float L = hsl.z;
    if (S < 1e-6) return vec3(L);
    float q = (L < 0.5) ? L * (1.0 + S) : L + S - L * S;
    float p = 2.0 * L - q;
    return vec3(
        hue2rgb(p, q, H + 1.0/3.0),
        hue2rgb(p, q, H),
        hue2rgb(p, q, H - 1.0/3.0)
    );
}

// Smooth weight for a hue range centered at 'center' (degrees), 60° wide
float hueWeight(float hue, float centerHue) {
    float d = abs(mod(hue - centerHue + 180.0, 360.0) - 180.0);
    return smoothstep(60.0, 15.0, d);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec3 c = IMG_NORM_PIXEL(inputImage, uv).rgb;

    vec3 hsl = rgb2hsl(c);

    // Per-range adjustments
    float wR = hueWeight(hsl.x, 0.0);    // Red
    float wG = hueWeight(hsl.x, 120.0);  // Green
    float wB = hueWeight(hsl.x, 240.0);  // Blue

    // Accumulate hue shifts and sat multipliers from active ranges
    float hueAdj = wR * red_hue + wG * green_hue + wB * blue_hue;
    float satMul = mix(1.0, red_sat, wR) * mix(1.0, green_sat, wG) * mix(1.0, blue_sat, wB);

    // Apply global + per-range
    hsl.x = mod(hsl.x + hue_shift + hueAdj, 360.0);
    hsl.y *= saturation * satMul;
    hsl.z *= luminance;

    gl_FragColor = vec4(hsl2rgb(hsl), IMG_NORM_PIXEL(inputImage, uv).a);
}
