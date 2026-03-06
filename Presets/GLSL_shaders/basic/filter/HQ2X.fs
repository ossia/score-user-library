
/*{
    "NAME": "HQ2X Scaler",
    "DESCRIPTION": "High-quality 2x pixel art upscaler that preserves detail and creates smooth edges",
    "ISFVSN": "2.0",
    "CREDIT": "HQ2X Algorithm Implementation",
    "CATEGORIES": [
        "Filter",
        "Upscale"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "threshold",
            "TYPE": "float",
            "DESCRIPTION": "Color difference threshold for edge detection",
            "MIN": 0.0,
            "MAX": 1.0,
            "DEFAULT": 0.3
        },
        {
            "NAME": "sharpness",
            "TYPE": "float",
            "DESCRIPTION": "Edge sharpness control",
            "MIN": 0.0,
            "MAX": 2.0,
            "DEFAULT": 1.0
        }
    ]
}*/

// Color comparison function - returns true if colors are similar
bool colorSimilar(vec3 c1, vec3 c2, float threshold) {
    vec3 diff = abs(c1 - c2);
    float maxDiff = max(max(diff.r, diff.g), diff.b);
    return maxDiff < threshold;
}

// YUV color difference for better perceptual comparison
float colorDifference(vec3 c1, vec3 c2) {
    // Convert to YUV for better perceptual difference
    vec3 yuv1 = vec3(
        0.299 * c1.r + 0.587 * c1.g + 0.114 * c1.b,
        -0.14713 * c1.r - 0.28886 * c1.g + 0.436 * c1.b,
        0.615 * c1.r - 0.51499 * c1.g - 0.10001 * c1.b
    );
    vec3 yuv2 = vec3(
        0.299 * c2.r + 0.587 * c2.g + 0.114 * c2.b,
        -0.14713 * c2.r - 0.28886 * c2.g + 0.436 * c2.b,
        0.615 * c2.r - 0.51499 * c2.g - 0.10001 * c2.b
    );
    return length(yuv1 - yuv2);
}

// Interpolate between colors with bias
vec3 interpolate(vec3 c1, vec3 c2, float weight) {
    return mix(c1, c2, weight);
}

// Interpolate three colors with weights
vec3 interpolate3(vec3 c1, vec3 c2, vec3 c3, float w1, float w2, float w3) {
    float total = w1 + w2 + w3;
    return (c1 * w1 + c2 * w2 + c3 * w3) / total;
}

void main() {
    vec2 uv = isf_FragNormCoord;

    // Calculate input texture size (512x512) vs output size (2048x2048)
    // This gives us a 4x upscale factor
    float scale = 4.0;
    vec2 inputTexelSize = 1.0 / vec2(512.0, 512.0);

    // Map output coordinates to input space
    vec2 inputUV = uv;

    // Get the exact input pixel we're sampling from
    vec2 inputPixel = floor(inputUV / inputTexelSize);
    vec2 inputPixelUV = inputPixel * inputTexelSize;

    // Calculate which sub-pixel within the 4x4 block we're rendering
    vec2 blockPos = fract(uv * 512.0);

    // For HQ2X, we work with 2x2 sub-blocks
    bool leftHalf = blockPos.x < 0.5;
    bool topHalf = blockPos.y < 0.5;

    // Sample the 3x3 neighborhood around the current pixel
    vec3 p1 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(-inputTexelSize.x, -inputTexelSize.y)).rgb; // top-left
    vec3 p2 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(0.0, -inputTexelSize.y)).rgb;                // top
    vec3 p3 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(inputTexelSize.x, -inputTexelSize.y)).rgb;   // top-right
    vec3 p4 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(-inputTexelSize.x, 0.0)).rgb;                // left
    vec3 p5 = IMG_NORM_PIXEL(inputImage, inputPixelUV).rgb;                                               // center
    vec3 p6 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(inputTexelSize.x, 0.0)).rgb;                 // right
    vec3 p7 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(-inputTexelSize.x, inputTexelSize.y)).rgb;   // bottom-left
    vec3 p8 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(0.0, inputTexelSize.y)).rgb;                 // bottom
    vec3 p9 = IMG_NORM_PIXEL(inputImage, inputPixelUV + vec2(inputTexelSize.x, inputTexelSize.y)).rgb;    // bottom-right

    vec3 result = p5; // Default to center pixel

    // Apply HQ2X logic based on pattern analysis
    if (topHalf && leftHalf) {
        // Top-left quadrant
        if (colorSimilar(p4, p2, threshold) && !colorSimilar(p4, p6, threshold) && !colorSimilar(p2, p8, threshold)) {
            // Diagonal edge detected
            if (colorSimilar(p1, p4, threshold) || colorSimilar(p1, p2, threshold)) {
                result = interpolate3(p4, p2, p5, 0.5, 0.5, 0.25);
            } else {
                result = interpolate(p4, p2, 0.5);
            }
        } else if (colorSimilar(p4, p2, threshold)) {
            result = interpolate3(p4, p2, p5, 0.4, 0.4, 0.2);
        } else {
            result = interpolate3(p4, p2, p5, 0.25, 0.25, 0.5);
        }
    }
    else if (topHalf && !leftHalf) {
        // Top-right quadrant
        if (colorSimilar(p2, p6, threshold) && !colorSimilar(p2, p4, threshold) && !colorSimilar(p6, p8, threshold)) {
            // Diagonal edge detected
            if (colorSimilar(p3, p2, threshold) || colorSimilar(p3, p6, threshold)) {
                result = interpolate3(p2, p6, p5, 0.5, 0.5, 0.25);
            } else {
                result = interpolate(p2, p6, 0.5);
            }
        } else if (colorSimilar(p2, p6, threshold)) {
            result = interpolate3(p2, p6, p5, 0.4, 0.4, 0.2);
        } else {
            result = interpolate3(p2, p6, p5, 0.25, 0.25, 0.5);
        }
    }
    else if (!topHalf && leftHalf) {
        // Bottom-left quadrant
        if (colorSimilar(p4, p8, threshold) && !colorSimilar(p4, p2, threshold) && !colorSimilar(p8, p6, threshold)) {
            // Diagonal edge detected
            if (colorSimilar(p7, p4, threshold) || colorSimilar(p7, p8, threshold)) {
                result = interpolate3(p4, p8, p5, 0.5, 0.5, 0.25);
            } else {
                result = interpolate(p4, p8, 0.5);
            }
        } else if (colorSimilar(p4, p8, threshold)) {
            result = interpolate3(p4, p8, p5, 0.4, 0.4, 0.2);
        } else {
            result = interpolate3(p4, p8, p5, 0.25, 0.25, 0.5);
        }
    }
    else {
        // Bottom-right quadrant
        if (colorSimilar(p6, p8, threshold) && !colorSimilar(p6, p2, threshold) && !colorSimilar(p8, p4, threshold)) {
            // Diagonal edge detected
            if (colorSimilar(p9, p6, threshold) || colorSimilar(p9, p8, threshold)) {
                result = interpolate3(p6, p8, p5, 0.5, 0.5, 0.25);
            } else {
                result = interpolate(p6, p8, 0.5);
            }
        } else if (colorSimilar(p6, p8, threshold)) {
            result = interpolate3(p6, p8, p5, 0.4, 0.4, 0.2);
        } else {
            result = interpolate3(p6, p8, p5, 0.25, 0.25, 0.5);
        }
    }

    // Apply sharpness enhancement
    if (sharpness > 1.0) {
        vec3 sharpened = result + (result - p5) * (sharpness - 1.0);
        result = mix(result, sharpened, 0.5);
    }

    // Ensure we maintain the original alpha
    float alpha = IMG_NORM_PIXEL(inputImage, inputPixelUV).a;

    gl_FragColor = vec4(result, alpha);
}
