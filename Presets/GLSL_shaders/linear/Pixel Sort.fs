/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Pixel sort glitch effect. Shifts pixels along rows or columns based on brightness, creating the distinctive glitch art look. Pixels above the threshold are displaced in the sort direction proportional to their brightness. Single-pass approximation of true pixel sorting that produces convincing results in real-time.",
    "CATEGORIES": [ "Glitch" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "threshold_low",  "LABEL": "Threshold Low",  "TYPE": "float", "DEFAULT": 0.2,  "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "threshold_high", "LABEL": "Threshold High", "TYPE": "float", "DEFAULT": 0.8,  "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "sort_strength",  "LABEL": "Sort Strength",  "TYPE": "float", "DEFAULT": 0.1,  "MIN": 0.0, "MAX": 0.3 },
        {
            "NAME": "sort_direction",
            "LABEL": "Direction",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2, 3 ],
            "LABELS": [ "Right", "Left", "Up", "Down" ]
        },
        { "NAME": "sort_randomize", "LABEL": "Randomize Rows", "TYPE": "float", "DEFAULT": 0.0,  "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

const vec3 luma_coeff = vec3(0.2126, 0.7152, 0.0722);

// Simple hash for row randomization
float hash(float n) {
    return fract(sin(n * 127.1) * 43758.5453);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    float L = dot(luma_coeff, orig.rgb);

    // Determine if this pixel is in the sorting range
    bool inRange = (L >= threshold_low && L <= threshold_high);

    if (!inRange || sort_strength < 0.001) {
        gl_FragColor = orig;
        return;
    }

    // Per-row/column randomization of sort amount
    float rowId;
    if (sort_direction <= 1) {
        rowId = floor(uv.y * RENDERSIZE.y);
    } else {
        rowId = floor(uv.x * RENDERSIZE.x);
    }
    float rowRand = mix(1.0, hash(rowId + 0.5), sort_randomize);

    // Sort displacement: brighter pixels move further in sort direction
    // Normalized luminance within threshold range
    float normalizedL = (L - threshold_low) / max(threshold_high - threshold_low, 0.001);
    float displacement = normalizedL * sort_strength * rowRand;

    vec2 sortUV = uv;
    if (sort_direction == 0) sortUV.x -= displacement;       // right: read from left
    else if (sort_direction == 1) sortUV.x += displacement;  // left: read from right
    else if (sort_direction == 2) sortUV.y -= displacement;  // up: read from below
    else sortUV.y += displacement;                            // down: read from above

    // Sample at displaced position
    vec4 sorted = IMG_NORM_PIXEL(inputImage, sortUV);
    float sortedL = dot(luma_coeff, sorted.rgb);

    // Only use the displaced sample if it's also in sorting range
    // This creates the "stretching" appearance of sorted regions
    bool sortedInRange = (sortedL >= threshold_low && sortedL <= threshold_high);
    if (sortedInRange) {
        gl_FragColor = sorted;
    } else {
        gl_FragColor = orig;
    }
}
