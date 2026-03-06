/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Pixelate / mosaic effect. Reduces spatial resolution by averaging pixel blocks. Multiple grid shapes. Averages in whatever space the input is in (correct for linear light). Works with HDR values.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "block_size",
            "LABEL": "Block Size",
            "TYPE": "float",
            "DEFAULT": 16.0,
            "MIN": 2.0,
            "MAX": 128.0
        },
        {
            "NAME": "shape",
            "LABEL": "Shape",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1, 2 ],
            "LABELS": [ "Square", "Hexagonal", "Circular" ]
        },
        {
            "NAME": "smooth_edges",
            "LABEL": "Smooth Edges",
            "TYPE": "bool",
            "DEFAULT": false
        }
    ]
}*/

// Hexagonal grid helper
vec2 hexCenter(vec2 p, float s) {
    // Axial hex coordinates
    float h = s * sqrt(3.0);
    float w = s * 2.0;
    vec2 a = vec2(w, 0.0);
    vec2 b = vec2(w * 0.5, h);

    vec2 ra = vec2(1.0 / a.x, 0.0);
    vec2 rb = vec2(-0.5 / a.x, 1.0 / b.y);

    float qa = floor(dot(p, ra) + 0.5);
    float qb = floor(dot(p, rb) + 0.5);

    vec2 c1 = qa * a + qb * b;
    vec2 c2 = c1 + a * 0.5 + b * 0.5;

    // Closest center
    return (length(p - c1) < length(p - c2)) ? c1 : c2;
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec2 px = block_size / RENDERSIZE;
    vec3 c;

    if (shape == 0) {
        // Square grid
        vec2 blockUV = floor(uv / px) * px + px * 0.5;
        c = IMG_NORM_PIXEL(inputImage, blockUV).rgb;

        if (smooth_edges) {
            // Blend at block edges for softer look
            vec2 f = fract(uv / px);
            vec2 edge = smoothstep(0.0, 0.15, f) * smoothstep(0.0, 0.15, 1.0 - f);
            float mask = edge.x * edge.y;
            vec3 orig = IMG_NORM_PIXEL(inputImage, uv).rgb;
            c = mix(orig, c, mask);
        }
    }
    else if (shape == 1) {
        // Hexagonal grid
        vec2 pixCoord = uv * RENDERSIZE;
        vec2 center = hexCenter(pixCoord, block_size * 0.5);
        vec2 hexUV = center / RENDERSIZE;
        c = IMG_NORM_PIXEL(inputImage, clamp(hexUV, 0.0, 1.0)).rgb;
    }
    else {
        // Circular (Voronoi-like from square grid, masked to circles)
        vec2 blockUV = floor(uv / px) * px + px * 0.5;
        c = IMG_NORM_PIXEL(inputImage, blockUV).rgb;

        // Circle mask within each block
        vec2 f = fract(uv / px) - 0.5;
        float dist = length(f);
        float circle = 1.0 - smoothstep(0.35, 0.5, dist);
        vec3 bg = IMG_NORM_PIXEL(inputImage, uv).rgb * 0.15;
        c = mix(bg, c, circle);
    }

    gl_FragColor = vec4(c, IMG_NORM_PIXEL(inputImage, uv).a);
}
