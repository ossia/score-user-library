/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Color Equalizer: adjust hue, saturation, and lightness independently for 6 color ranges across the full hue wheel (red, yellow, green, cyan, blue, magenta). Inspired by darktable's color equalizer / color zones and Resolve's Hue vs Hue + Hue vs Sat + Hue vs Lum curves unified in one tool. The professional way to do selective color work.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "red_hue",     "LABEL": "Red Hue",     "TYPE": "float", "DEFAULT": 0.0, "MIN": -30.0, "MAX": 30.0 },
        { "NAME": "red_sat",     "LABEL": "Red Sat",     "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 3.0 },
        { "NAME": "red_lum",     "LABEL": "Red Lum",     "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.5, "MAX": 2.0 },
        { "NAME": "yellow_hue",  "LABEL": "Yellow Hue",  "TYPE": "float", "DEFAULT": 0.0, "MIN": -30.0, "MAX": 30.0 },
        { "NAME": "yellow_sat",  "LABEL": "Yellow Sat",  "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 3.0 },
        { "NAME": "yellow_lum",  "LABEL": "Yellow Lum",  "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.5, "MAX": 2.0 },
        { "NAME": "green_hue",   "LABEL": "Green Hue",   "TYPE": "float", "DEFAULT": 0.0, "MIN": -30.0, "MAX": 30.0 },
        { "NAME": "green_sat",   "LABEL": "Green Sat",   "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 3.0 },
        { "NAME": "green_lum",   "LABEL": "Green Lum",   "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.5, "MAX": 2.0 },
        { "NAME": "cyan_hue",    "LABEL": "Cyan Hue",    "TYPE": "float", "DEFAULT": 0.0, "MIN": -30.0, "MAX": 30.0 },
        { "NAME": "cyan_sat",    "LABEL": "Cyan Sat",    "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 3.0 },
        { "NAME": "cyan_lum",    "LABEL": "Cyan Lum",    "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.5, "MAX": 2.0 },
        { "NAME": "blue_hue",    "LABEL": "Blue Hue",    "TYPE": "float", "DEFAULT": 0.0, "MIN": -30.0, "MAX": 30.0 },
        { "NAME": "blue_sat",    "LABEL": "Blue Sat",    "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 3.0 },
        { "NAME": "blue_lum",    "LABEL": "Blue Lum",    "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.5, "MAX": 2.0 },
        { "NAME": "magenta_hue", "LABEL": "Magenta Hue", "TYPE": "float", "DEFAULT": 0.0, "MIN": -30.0, "MAX": 30.0 },
        { "NAME": "magenta_sat", "LABEL": "Magenta Sat", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 3.0 },
        { "NAME": "magenta_lum", "LABEL": "Magenta Lum", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.5, "MAX": 2.0 },
        {
            "NAME": "range_width",
            "LABEL": "Range Width (degrees)",
            "TYPE": "float",
            "DEFAULT": 45.0,
            "MIN": 20.0,
            "MAX": 80.0
        }
    ]
}*/

const vec3 luma_coeff = vec3(0.2126, 0.7152, 0.0722);

// 6 range centers on the hue wheel (degrees)
// Red=0, Yellow=60, Green=120, Cyan=180, Blue=240, Magenta=300
const float HUE_CENTERS[6] = float[6](0.0, 60.0, 120.0, 180.0, 240.0, 300.0);

// Smooth hue weight: cosine bell centered at 'center', width controlled by range_width
// Returns 0-1 weight, wrapping around 360°
float hueWeight(float hue, float center, float width) {
    float d = abs(mod(hue - center + 180.0, 360.0) - 180.0);
    return smoothstep(width, width * 0.3, d);
}

// Extract hue in degrees from RGB (simplified, works for any value range)
float rgbToHue(vec3 c) {
    float maxC = max(c.r, max(c.g, c.b));
    float minC = min(c.r, min(c.g, c.b));
    float d = maxC - minC;
    if (d < 1e-6) return 0.0;

    float h;
    if (maxC == c.r)      h = mod((c.g - c.b) / d, 6.0);
    else if (maxC == c.g) h = (c.b - c.r) / d + 2.0;
    else                   h = (c.r - c.g) / d + 4.0;
    h *= 60.0;
    if (h < 0.0) h += 360.0;
    return h;
}

// Rotate hue in RGB space (simplified Rodrigues' rotation around luminance axis)
vec3 rotateHue(vec3 c, float L, float angleDeg) {
    if (abs(angleDeg) < 0.01) return c;
    float angle = angleDeg * 3.14159265 / 180.0;
    float cosA = cos(angle);
    float sinA = sin(angle);
    // Rotate the chrominance (c - L) around the gray axis
    // Approximate: decompose into two orthogonal chroma axes
    vec3 chroma = c - L;
    // Use a YIQ-like rotation for hue shift
    float I = dot(chroma, vec3(0.5959, -0.2746, -0.3213));
    float Q = dot(chroma, vec3(0.2115, -0.5227, 0.3112));
    float Ir = I * cosA - Q * sinA;
    float Qr = I * sinA + Q * cosA;
    // Reconstruct
    vec3 rotated = vec3(
        L + 0.956 * Ir + 0.621 * Qr,
        L - 0.272 * Ir - 0.647 * Qr,
        L - 1.107 * Ir + 1.704 * Qr
    );
    return rotated;
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    float L = dot(luma_coeff, c);
    float hue = rgbToHue(c);

    // Gather per-range parameters into arrays for the loop
    float hueAdjs[6]  = float[6](red_hue, yellow_hue, green_hue, cyan_hue, blue_hue, magenta_hue);
    float satAdjs[6]  = float[6](red_sat, yellow_sat, green_sat, cyan_sat, blue_sat, magenta_sat);
    float lumAdjs[6]  = float[6](red_lum, yellow_lum, green_lum, cyan_lum, blue_lum, magenta_lum);

    // Accumulate weighted adjustments from all 6 ranges
    float totalHueShift = 0.0;
    float totalSatMul   = 1.0;
    float totalLumMul   = 1.0;
    float totalWeight   = 0.0;

    for (int i = 0; i < 6; i++) {
        float w = hueWeight(hue, HUE_CENTERS[i], range_width);
        if (w > 0.001) {
            totalHueShift += w * hueAdjs[i];
            // Multiplicative blending for sat and lum
            totalSatMul *= mix(1.0, satAdjs[i], w);
            totalLumMul *= mix(1.0, lumAdjs[i], w);
            totalWeight += w;
        }
    }

    // Apply hue rotation
    if (abs(totalHueShift) > 0.01 && L > 1e-6) {
        c = rotateHue(c, L, totalHueShift);
    }

    // Apply saturation (mix toward/away from luminance)
    if (totalSatMul != 1.0 && L > 1e-6) {
        c = L + (c - L) * totalSatMul;
    }

    // Apply luminance scaling
    if (totalLumMul != 1.0) {
        c *= totalLumMul;
    }

    gl_FragColor = vec4(c, orig.a);
}
