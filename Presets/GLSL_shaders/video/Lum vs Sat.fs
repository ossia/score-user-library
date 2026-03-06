/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Luminance vs Saturation: adjust saturation independently for shadows, midtones, and highlights. The tool that creates the classic 'desaturated shadows with vivid midtones' film look. Equivalent to Resolve's Lum vs Sat curve. Zone boundaries are configurable. Linear-pipeline safe.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "shadow_sat",
            "LABEL": "Shadow Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "midtone_sat",
            "LABEL": "Midtone Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "highlight_sat",
            "LABEL": "Highlight Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 3.0
        },
        {
            "NAME": "shadow_end",
            "LABEL": "Shadow ↔ Mid Transition",
            "TYPE": "float",
            "DEFAULT": 0.3,
            "MIN": 0.05,
            "MAX": 0.6
        },
        {
            "NAME": "highlight_start",
            "LABEL": "Mid ↔ Highlight Transition",
            "TYPE": "float",
            "DEFAULT": 0.7,
            "MIN": 0.4,
            "MAX": 0.95
        }
    ]
}*/

// Zone masking: darktable/Unity model
// Three overlapping soft masks based on luminance.

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    float L = dot(luma, c);

    // Zone weights with smooth transitions
    float wShadow    = 1.0 - smoothstep(0.0, shadow_end, L);
    float wHighlight  = smoothstep(highlight_start, 1.0, L);
    float wMidtone    = 1.0 - wShadow - wHighlight;

    // Ensure non-negative (can happen if shadow_end > highlight_start)
    wMidtone = max(wMidtone, 0.0);

    // Weighted saturation factor
    float satFactor = wShadow * shadow_sat
                    + wMidtone * midtone_sat
                    + wHighlight * highlight_sat;

    // Apply saturation change (mix toward/away from luminance)
    if (L > 1e-6) {
        c = L + (c - L) * satFactor;
    }

    gl_FragColor = vec4(c, orig.a);
}
