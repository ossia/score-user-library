/*{
    "NAME": "Bilateral denoise",
    "DESCRIPTION": "Reduces noise from a high-ISO camera feed using a bilateral filter.",
    "ISFVSN": "2.0",
    "CREDIT": "Jean-Michaël Celerier",
    "CATEGORIES": [
        "Filter",
        "Cleanup"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "noiseReduction",
            "TYPE": "float",
            "DESCRIPTION": "How much noise to remove. Higher values are stronger but can lose detail.",
            "MIN": 0.0,
            "MAX": 1.0,
            "DEFAULT": 0.3
        },
        {
            "NAME": "sharpness",
            "TYPE": "float",
            "DESCRIPTION": "How much to preserve edges. Higher values keep more detail.",
            "MIN": 1.0,
            "MAX": 50.0,
            "DEFAULT": 15.0
        },
        {
            "NAME": "kernelSize",
            "TYPE": "long",
            "DESCRIPTION": "The area to sample for noise. Larger will be slower.",
            "MIN": 1,
            "MAX": 10,
            "VALUES": [1,2,3,4,5,6,7,8,9,10]
        }
    ]
}*/

// Calculate similarity between two colors for bilateral filtering
float colorSimilarity(vec3 color1, vec3 color2, float sharpness) {
    float luma1 = dot(color1, vec3(0.299, 0.587, 0.114));
    float luma2 = dot(color2, vec3(0.299, 0.587, 0.114));
    float lumaDifference = abs(luma1 - luma2);
    return exp(-sharpness * lumaDifference);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 originalColor = IMG_NORM_PIXEL(inputImage, uv);

    vec3 finalColor = vec3(0.0);
    float totalWeight = 0.0;

    vec2 texelSize = 1.0 / RENDERSIZE;

    // Bilateral filter implementation
    for (int x = -kernelSize; x <= kernelSize; ++x) {
        for (int y = -kernelSize; y <= kernelSize; ++y) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            vec2 sampleUV = uv + offset;
            vec4 neighborColor = IMG_NORM_PIXEL(inputImage, sampleUV);

            float pixelDistance = length(vec2(float(x), float(y)));
            float spatialSigma = max(1.0, noiseReduction * 10.0);
            float spatialWeight = exp(-(pixelDistance * pixelDistance) / (2.0 * spatialSigma * spatialSigma));

            float colorWeight = colorSimilarity(originalColor.rgb, neighborColor.rgb, sharpness);
            float weight = spatialWeight * colorWeight;

            finalColor += neighborColor.rgb * weight;
            totalWeight += weight;
        }
    }

    if (totalWeight > 0.001) {
        finalColor /= totalWeight;
    } else {
        finalColor = originalColor.rgb;
    }

    gl_FragColor = vec4(finalColor, originalColor.a);
}
