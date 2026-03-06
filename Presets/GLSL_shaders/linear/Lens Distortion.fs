/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Lens distortion using the Brown-Conrady model. Barrel distortion (positive k) simulates wide-angle/fisheye lenses; pincushion (negative k) simulates telephoto. Optional per-channel distortion creates chromatic fringing like a real lens. Works on any value range.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "distortion_k1",
            "LABEL": "Distortion (k1)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -1.0,
            "MAX": 1.0
        },
        {
            "NAME": "distortion_k2",
            "LABEL": "Distortion (k2)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "chromatic_fringe",
            "LABEL": "Chromatic Fringing",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": 0.0,
            "MAX": 0.03
        },
        {
            "NAME": "center",
            "LABEL": "Center",
            "TYPE": "point2D",
            "DEFAULT": [ 0.5, 0.5 ]
        },
        {
            "NAME": "scale",
            "LABEL": "Scale Compensation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.5,
            "MAX": 2.0
        },
        {
            "NAME": "edge_mode",
            "LABEL": "Edge Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1 ],
            "LABELS": [ "Black", "Clamp to Edge" ]
        }
    ]
}*/

// Brown-Conrady distortion model
// r_distorted = r * (1 + k1*r² + k2*r⁴)
vec2 distort(vec2 uv, float k1_adj, float k2_adj) {
    float aspect = RENDERSIZE.x / RENDERSIZE.y;
    vec2 d = (uv - center) * vec2(aspect, 1.0);
    float r2 = dot(d, d);
    float r4 = r2 * r2;
    float f = 1.0 + k1_adj * r2 + k2_adj * r4;
    vec2 distorted = center + d * f / vec2(aspect, 1.0);
    // Scale compensation to fill frame
    distorted = center + (distorted - center) / scale;
    return distorted;
}

vec3 sampleAt(vec2 uv) {
    if (edge_mode == 0) {
        // Black outside
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
            return vec3(0.0);
    }
    return IMG_NORM_PIXEL(inputImage, clamp(uv, 0.0, 1.0)).rgb;
}

void main() {
    vec2 uv = isf_FragNormCoord;

    if (chromatic_fringe > 0.001) {
        // Per-channel distortion: R gets slightly more, B slightly less
        float r_k1 = distortion_k1 * (1.0 + chromatic_fringe * 10.0);
        float g_k1 = distortion_k1;
        float b_k1 = distortion_k1 * (1.0 - chromatic_fringe * 10.0);

        float r = sampleAt(distort(uv, r_k1, distortion_k2)).r;
        float g = sampleAt(distort(uv, g_k1, distortion_k2)).g;
        float b = sampleAt(distort(uv, b_k1, distortion_k2)).b;
        gl_FragColor = vec4(r, g, b, IMG_NORM_PIXEL(inputImage, uv).a);
    } else {
        // Uniform distortion
        vec2 distortedUV = distort(uv, distortion_k1, distortion_k2);
        vec3 c = sampleAt(distortedUV);
        gl_FragColor = vec4(c, IMG_NORM_PIXEL(inputImage, uv).a);
    }
}
