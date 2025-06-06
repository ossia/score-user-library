/*{
    "NAME": "Artistic Sharpening",
    "DESCRIPTION": "Multi-tool for sharpening images",
    "ISFVSN": "2.0",
    "CREDIT": "Jean-Michaël Celerier",
    "CATEGORIES": [
        "Filter",
        "Enhancement"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "sharpness",
            "TYPE": "float",
            "DESCRIPTION": "Overall sharpening strength",
            "MIN": 0.0,
            "MAX": 3.0,
            "DEFAULT": 1.2
        },
        {
            "NAME": "edgeThreshold",
            "TYPE": "float",
            "DESCRIPTION": "Threshold for edge detection - higher values affect more areas",
            "MIN": 0.0,
            "MAX": 1.0,
            "DEFAULT": 0.15
        },
        {
            "NAME": "softAreaProtection",
            "TYPE": "float",
            "DESCRIPTION": "Protects soft gradients and subtle transitions",
            "MIN": 0.0,
            "MAX": 1.0,
            "DEFAULT": 0.7
        },
        {
            "NAME": "colorPreservation",
            "TYPE": "float",
            "DESCRIPTION": "Maintains color relationships and saturation",
            "MIN": 0.0,
            "MAX": 1.0,
            "DEFAULT": 0.8
        },
        {
            "NAME": "contrastBoost",
            "TYPE": "float",
            "DESCRIPTION": "Subtle contrast enhancement for definition",
            "MIN": 0.0,
            "MAX": 2.0,
            "DEFAULT": 0.3
        },
        {
            "NAME": "luminanceWeight",
            "TYPE": "float",
            "DESCRIPTION": "How much to weight luminance vs color in sharpening",
            "MIN": 0.0,
            "MAX": 1.0,
            "DEFAULT": 0.6
        }
    ]
}*/

// Convert RGB to perceptual luminance
float getLuminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

// Convert RGB to HSV for color-aware processing
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Convert HSV back to RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Detect edges using Sobel operator with artistic sensitivity
float detectEdges(vec2 uv, vec2 texelSize) {
    // Sample 3x3 neighborhood
    float tl = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(-texelSize.x, -texelSize.y)).rgb);
    float tm = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(0.0, -texelSize.y)).rgb);
    float tr = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(texelSize.x, -texelSize.y)).rgb);
    float ml = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(-texelSize.x, 0.0)).rgb);
    float mm = getLuminance(IMG_NORM_PIXEL(inputImage, uv).rgb);
    float mr = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(texelSize.x, 0.0)).rgb);
    float bl = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(-texelSize.x, texelSize.y)).rgb);
    float bm = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(0.0, texelSize.y)).rgb);
    float br = getLuminance(IMG_NORM_PIXEL(inputImage, uv + vec2(texelSize.x, texelSize.y)).rgb);

    // Sobel X and Y gradients
    float sobelX = (tr + 2.0 * mr + br) - (tl + 2.0 * ml + bl);
    float sobelY = (bl + 2.0 * bm + br) - (tl + 2.0 * tm + tr);

    return sqrt(sobelX * sobelX + sobelY * sobelY);
}

// Calculate local variance for soft area detection
float calculateVariance(vec2 uv, vec2 texelSize) {
    vec3 colors[9];
    colors[0] = IMG_NORM_PIXEL(inputImage, uv + vec2(-texelSize.x, -texelSize.y)).rgb;
    colors[1] = IMG_NORM_PIXEL(inputImage, uv + vec2(0.0, -texelSize.y)).rgb;
    colors[2] = IMG_NORM_PIXEL(inputImage, uv + vec2(texelSize.x, -texelSize.y)).rgb;
    colors[3] = IMG_NORM_PIXEL(inputImage, uv + vec2(-texelSize.x, 0.0)).rgb;
    colors[4] = IMG_NORM_PIXEL(inputImage, uv).rgb;
    colors[5] = IMG_NORM_PIXEL(inputImage, uv + vec2(texelSize.x, 0.0)).rgb;
    colors[6] = IMG_NORM_PIXEL(inputImage, uv + vec2(-texelSize.x, texelSize.y)).rgb;
    colors[7] = IMG_NORM_PIXEL(inputImage, uv + vec2(0.0, texelSize.y)).rgb;
    colors[8] = IMG_NORM_PIXEL(inputImage, uv + vec2(texelSize.x, texelSize.y)).rgb;

    // Calculate mean
    vec3 mean = vec3(0.0);
    for (int i = 0; i < 9; i++) {
        mean += colors[i];
    }
    mean /= 9.0;

    // Calculate variance
    float variance = 0.0;
    for (int i = 0; i < 9; i++) {
        vec3 diff = colors[i] - mean;
        variance += dot(diff, diff);
    }
    return variance / 9.0;
}

// Unsharp mask with artistic sensitivity
vec3 unsharpMask(vec2 uv, vec2 texelSize, float strength) {
    vec3 original = IMG_NORM_PIXEL(inputImage, uv).rgb;

    // Create a subtle gaussian blur
    vec3 blurred = vec3(0.0);
    float weights[9] = float[](1.0, 2.0, 1.0, 2.0, 4.0, 2.0, 1.0, 2.0, 1.0);
    float totalWeight = 16.0;

    int index = 0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 sampleUV = uv + vec2(float(x), float(y)) * texelSize;
            blurred += IMG_NORM_PIXEL(inputImage, sampleUV).rgb * weights[index] / totalWeight;
            index++;
        }
    }

    // Create sharpening mask
    vec3 mask = original - blurred;

    return original + mask * strength;
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec2 texelSize = 1.0 / RENDERSIZE;

    vec4 originalColor = IMG_NORM_PIXEL(inputImage, uv);
    vec3 color = originalColor.rgb;

    // Edge detection
    float edgeStrength = detectEdges(uv, texelSize);
    float isEdge = smoothstep(edgeThreshold * 0.5, edgeThreshold, edgeStrength);

    // Soft area detection
    float variance = calculateVariance(uv, texelSize);
    float isSoftArea = 1.0 - smoothstep(0.001, 0.01, variance);

    // Apply unsharp masking
    vec3 sharpened = unsharpMask(uv, texelSize, sharpness);

    // Blend based on edge detection and soft area protection
    float sharpenAmount = isEdge * (1.0 - isSoftArea * softAreaProtection);
    color = mix(color, sharpened, sharpenAmount);

    // Color preservation - maintain original color relationships
    if (colorPreservation > 0.0) {
        vec3 originalHSV = rgb2hsv(originalColor.rgb);
        vec3 sharpenedHSV = rgb2hsv(color);

        // Preserve hue and partially preserve saturation
        sharpenedHSV.x = originalHSV.x; // Keep original hue
        sharpenedHSV.y = mix(sharpenedHSV.y, originalHSV.y, colorPreservation * 0.5);

        color = hsv2rgb(sharpenedHSV);
    }

    // Luminance-based sharpening for fine details
    if (luminanceWeight > 0.0) {
        float originalLuma = getLuminance(originalColor.rgb);
        float sharpenedLuma = getLuminance(color);
        float lumaEnhancement = (sharpenedLuma - originalLuma) * luminanceWeight;

        // Apply luminance enhancement while preserving color
        color = originalColor.rgb + vec3(lumaEnhancement);
    }

    // Subtle contrast boost
    if (contrastBoost > 0.0) {
        vec3 midtone = vec3(0.5);
        color = mix(color, midtone + (color - midtone) * (1.0 + contrastBoost),
                   isEdge * contrastBoost * 0.3);
    }

    // Ensure we don't exceed valid color range
    color = clamp(color, 0.0, 1.0);

    gl_FragColor = vec4(color, originalColor.a);
}
