/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Shadows and highlights recovery. Lifts shadows and recovers highlights independently using luminance-based zone masking with smooth transitions. Includes saturation compensation to avoid desaturated lifted shadows or over-saturated darkened highlights. Based on darktable/Resolve zone model. Linear-pipeline safe.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "shadows_amount",
            "LABEL": "Shadows",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -1.0,
            "MAX": 1.0
        },
        {
            "NAME": "highlights_amount",
            "LABEL": "Highlights",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -1.0,
            "MAX": 1.0
        },
        {
            "NAME": "shadow_tone_width",
            "LABEL": "Shadow Width",
            "TYPE": "float",
            "DEFAULT": 0.4,
            "MIN": 0.05,
            "MAX": 0.8
        },
        {
            "NAME": "highlight_tone_width",
            "LABEL": "Highlight Width",
            "TYPE": "float",
            "DEFAULT": 0.6,
            "MIN": 0.2,
            "MAX": 0.95
        },
        {
            "NAME": "shadow_saturation",
            "LABEL": "Shadow Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 2.0
        },
        {
            "NAME": "highlight_saturation",
            "LABEL": "Highlight Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 2.0
        }
    ]
}*/

// Zone masking approach from darktable colorbalancergb / Unity URP:
// Shadow weight is high for dark pixels, fades to 0 at shadow_tone_width.
// Highlight weight is high for bright pixels, fades to 0 at highlight_tone_width.
// Midtones are untouched (weight = 1 - shadow - highlight).

const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    float L = dot(luma, c);
    if (L <= 0.0 && shadows_amount <= 0.0) {
        gl_FragColor = orig;
        return;
    }

    // Zone weights (darktable/Unity model)
    // Shadow zone: full at L=0, fading to 0 at shadow_tone_width
    float shadowWeight = 1.0 - smoothstep(0.0, shadow_tone_width, L);

    // Highlight zone: 0 at highlight_tone_width, full at L=1
    float highlightWeight = smoothstep(highlight_tone_width, 1.0, L);

    // Shadow adjustment:
    // Positive = lift shadows (add light), negative = crush shadows
    // Scale the effect by the zone weight
    // We use a power-based approach: raising dark values brightens them
    float shadowFactor = 1.0 + shadows_amount * shadowWeight;

    // Highlight adjustment:
    // Negative = recover highlights (darken), positive = push highlights
    float highlightFactor = 1.0 + highlights_amount * highlightWeight;

    // Apply factors
    // For shadows: multiply by factor (> 1 lifts, < 1 crushes)
    // For highlights: multiply by factor (< 1 recovers, > 1 pushes)
    float combinedFactor = shadowFactor * highlightFactor;

    // Apply luminance-preserving adjustment:
    // Scale all channels by the combined factor
    vec3 adjusted = c * combinedFactor;

    // Saturation compensation
    // Lifted shadows tend to look desaturated; darktable recommends
    // a saturation boost proportional to the lift amount.
    // Darkened highlights may over-saturate; offer control.
    float newL = dot(luma, adjusted);
    if (newL > 1e-6) {
        float satScale = 1.0;

        // Shadow saturation: apply in shadow zone
        if (shadowWeight > 0.0 && shadow_saturation != 1.0) {
            satScale *= mix(1.0, shadow_saturation, shadowWeight * abs(shadows_amount));
        }

        // Highlight saturation: apply in highlight zone
        if (highlightWeight > 0.0 && highlight_saturation != 1.0) {
            satScale *= mix(1.0, highlight_saturation, highlightWeight * abs(highlights_amount));
        }

        if (satScale != 1.0) {
            adjusted = newL + (adjusted - newL) * satScale;
        }
    }

    gl_FragColor = vec4(adjusted, orig.a);
}
