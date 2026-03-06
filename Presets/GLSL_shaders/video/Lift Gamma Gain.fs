/*{
    "CREDIT": "ossia score video utilities",
    "ISFVSN": "2",
    "DESCRIPTION": "Three-way color corrector: Lift (shadows), Gamma (midtones), Gain (highlights). The standard grading tool for any video workflow. Operates per-channel for color tinting or uniformly for neutral adjustments.",
    "CATEGORIES": [
        "Color"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "lift",
            "LABEL": "Lift (Shadows)",
            "TYPE": "color",
            "DEFAULT": [ 0.0, 0.0, 0.0, 1.0 ]
        },
        {
            "NAME": "gamma",
            "LABEL": "Gamma (Midtones)",
            "TYPE": "color",
            "DEFAULT": [ 1.0, 1.0, 1.0, 1.0 ]
        },
        {
            "NAME": "gain",
            "LABEL": "Gain (Highlights)",
            "TYPE": "color",
            "DEFAULT": [ 1.0, 1.0, 1.0, 1.0 ]
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
            "NAME": "contrast",
            "LABEL": "Contrast",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "contrast_pivot",
            "LABEL": "Contrast Pivot",
            "TYPE": "float",
            "DEFAULT": 0.18,
            "MIN": 0.01,
            "MAX": 1.0
        },
        {
            "NAME": "temperature",
            "LABEL": "Temperature",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -1.0,
            "MAX": 1.0
        },
        {
            "NAME": "tint",
            "LABEL": "Tint (Green-Magenta)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -1.0,
            "MAX": 1.0
        }
    ]
}*/

// BT.709 luma for saturation
const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    // ── Lift / Gamma / Gain ──
    // Formula: output = gain * (input + lift * (1 - input)) ^ (1/gamma)
    // At black (0): output = gain * lift
    // At white (1): output = gain
    // Midtones shaped by gamma power
    vec3 L = lift.rgb;
    vec3 G = gamma.rgb;
    vec3 Gn = gain.rgb;

    // Prevent division by zero in gamma
    G = max(G, 0.001);

    c = Gn * pow(max(c + L * (1.0 - c), 0.0), 1.0 / G);

    // ── Contrast (around pivot) ──
    if (contrast != 1.0) {
        c = contrast_pivot * pow(max(c / contrast_pivot, 0.0), vec3(contrast));
    }

    // ── Temperature / Tint ──
    // Simple RGB-domain approximation.
    // Temperature: warm (positive) shifts blue→red
    // Tint: positive shifts green→magenta
    if (temperature != 0.0 || tint != 0.0) {
        float t = temperature * 0.1;
        float ti = tint * 0.1;
        c.r += t;
        c.b -= t;
        c.g -= ti;
        c.r += ti * 0.5;
        c.b += ti * 0.5;
    }

    // ── Saturation ──
    if (saturation != 1.0) {
        float L_val = dot(luma, c);
        c = mix(vec3(L_val), c, saturation);
    }

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
