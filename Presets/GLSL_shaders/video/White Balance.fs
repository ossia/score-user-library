/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "White balance via chromatic adaptation (CAT16). Unlike simple RGB multipliers that only fix neutral grays, this adapts all colors perceptually as if the scene were lit by a different illuminant. Based on CIE CAT16 from darktable's color calibration module. Operates on linear-light BT.709/sRGB data. Source temperature = what the scene was lit by; target = desired illuminant (usually D65 = 6500K).",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "source_temperature",
            "LABEL": "Source Temperature (K)",
            "TYPE": "float",
            "DEFAULT": 6500.0,
            "MIN": 2000.0,
            "MAX": 15000.0
        },
        {
            "NAME": "target_temperature",
            "LABEL": "Target Temperature (K)",
            "TYPE": "float",
            "DEFAULT": 6500.0,
            "MIN": 2000.0,
            "MAX": 15000.0
        },
        {
            "NAME": "tint",
            "LABEL": "Tint (green-magenta)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.1,
            "MAX": 0.1
        },
        {
            "NAME": "adaptation_strength",
            "LABEL": "Adaptation Strength",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 1.0
        }
    ]
}*/

// CIE CAT16 chromatic adaptation transform matrices
// Reference: CIE 224:2017, Li et al. 2017
// These transform from XYZ to the CAT16 "sharpened" LMS cone space

const mat3 XYZ_to_CAT16 = mat3(
     0.401288, -0.250268,  -0.002079,
     0.650173,  1.204414,   0.048952,
    -0.051461,  0.045854,   0.953127
);

const mat3 CAT16_to_XYZ = mat3(
     1.862068,  0.387527, -0.015841,
    -1.011255,  0.621447, -0.034123,
     0.149187, -0.008974,  1.049964
);

// sRGB/BT.709 ↔ XYZ (D65) matrices
const mat3 RGB_to_XYZ = mat3(
    0.4124564, 0.2126729, 0.0193339,
    0.3575761, 0.7151522, 0.1191920,
    0.1804375, 0.0721750, 0.9503041
);

const mat3 XYZ_to_RGB = mat3(
     3.2404542, -0.9692660,  0.0556434,
    -1.5371385,  1.8760108, -0.2040259,
    -0.4985314,  0.0415560,  1.0572252
);

// CIE Daylight illuminant chromaticity from CCT (Hernandez-Andrés 1999)
// Returns CIE xy chromaticity for a given color temperature in Kelvin.
vec2 cctToXY(float T) {
    float T2 = T * T;
    float T3 = T2 * T;

    float x;
    if (T <= 7000.0) {
        x = -4.6070e9 / T3 + 2.9678e6 / T2 + 0.09911e3 / T + 0.244063;
    } else {
        x = -2.0064e9 / T3 + 1.9018e6 / T2 + 0.24748e3 / T + 0.237040;
    }

    // CIE daylight locus y from x (McCamy approximation extended)
    float y = -3.0 * x * x + 2.87 * x - 0.275;

    return vec2(x, y);
}

// Convert CIE xy to XYZ white point (Y=1)
vec3 xyToXYZ(vec2 xy) {
    return vec3(xy.x / xy.y, 1.0, (1.0 - xy.x - xy.y) / xy.y);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    // If source == target and no tint, pass through
    if (abs(source_temperature - target_temperature) < 1.0
        && abs(tint) < 0.001) {
        gl_FragColor = orig;
        return;
    }

    // Compute source and target illuminant white points
    vec2 srcXY = cctToXY(source_temperature);
    vec2 tgtXY = cctToXY(target_temperature);

    // Apply tint (shift along green-magenta axis, perpendicular to Planckian locus)
    srcXY.y += tint;

    vec3 srcWhiteXYZ = xyToXYZ(srcXY);
    vec3 tgtWhiteXYZ = xyToXYZ(tgtXY);

    // Transform white points to CAT16 LMS
    vec3 srcLMS = XYZ_to_CAT16 * srcWhiteXYZ;
    vec3 tgtLMS = XYZ_to_CAT16 * tgtWhiteXYZ;

    // Von Kries diagonal adaptation in CAT16 space
    // D = adaptation degree (1.0 = full adaptation, darktable default)
    float D = adaptation_strength;
    vec3 gain = mix(vec3(1.0), tgtLMS / max(srcLMS, 1e-10), D);

    // Full transform: RGB to XYZ to CAT16 to adapt to CAT16⁻¹ to XYZ to RGB
    // We compose this as a single matrix chain for efficiency
    vec3 xyz = RGB_to_XYZ * c;
    vec3 lms = XYZ_to_CAT16 * xyz;
    lms *= gain;
    xyz = CAT16_to_XYZ * lms;
    c = XYZ_to_RGB * xyz;

    gl_FragColor = vec4(c, orig.a);
}
