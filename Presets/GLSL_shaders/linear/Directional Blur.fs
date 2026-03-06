/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Directional (motion) blur along a specified angle. Uses a 31-tap Gaussian-weighted kernel for smooth results. Directional blur is inherently 1D so a single pass is correct — no multipass needed. Linear-safe.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "angle",
            "LABEL": "Direction (degrees)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": 0.0,
            "MAX": 360.0
        },
        {
            "NAME": "amount",
            "LABEL": "Amount",
            "TYPE": "float",
            "DEFAULT": 3.0,
            "MIN": 0.0,
            "MAX": 10.0
        },
        {
            "NAME": "samples",
            "LABEL": "Quality",
            "TYPE": "long",
            "DEFAULT": 1,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Low (11)", "Medium (21)", "High (31)" ]
        }
    ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;

    if (amount < 0.5) {
        gl_FragColor = IMG_NORM_PIXEL(inputImage, uv);
        return;
    }

    float rad = angle * 3.14159265 / 180.0;
    vec2 dir = vec2(cos(rad), sin(rad)) / RENDERSIZE * amount;

    int numSamples;
    if (samples == 0) numSamples = 11;
    else if (samples == 1) numSamples = 21;
    else numSamples = 31;

    // Gaussian weighting: sigma = numSamples/6 so ±3σ covers the kernel
    float sigma = float(numSamples) / 6.0;
    float invSigma2 = 1.0 / (2.0 * sigma * sigma);

    vec3 sum = vec3(0.0);
    float totalWeight = 0.0;

    for (int i = 0; i < 31; i++) {
        if (i >= numSamples) break;

        float t = float(i) - float(numSamples - 1) * 0.5;
        vec2 sampleUV = uv + dir * t / float(numSamples - 1) * 2.0;

        // Gaussian weight
        float w = exp(-t * t * invSigma2);

        sum += IMG_NORM_PIXEL(inputImage, sampleUV).rgb * w;
        totalWeight += w;
    }

    gl_FragColor = vec4(sum / totalWeight, IMG_NORM_PIXEL(inputImage, uv).a);
}
