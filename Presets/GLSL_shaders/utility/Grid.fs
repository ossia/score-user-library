/*{
    "CATEGORIES": [
        "Utility"
    ],
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Display up to 16 image inputs in a mosaic grid for previsualization. The grid layout adapts automatically to the number of active inputs.",
    "INPUTS": [
        { "NAME": "t0",  "LABEL": "Texture 1",  "TYPE": "image" },
        { "NAME": "t1",  "LABEL": "Texture 2",  "TYPE": "image" },
        { "NAME": "t2",  "LABEL": "Texture 3",  "TYPE": "image" },
        { "NAME": "t3",  "LABEL": "Texture 4",  "TYPE": "image" },
        { "NAME": "t4",  "LABEL": "Texture 5",  "TYPE": "image" },
        { "NAME": "t5",  "LABEL": "Texture 6",  "TYPE": "image" },
        { "NAME": "t6",  "LABEL": "Texture 7",  "TYPE": "image" },
        { "NAME": "t7",  "LABEL": "Texture 8",  "TYPE": "image" },
        { "NAME": "t8",  "LABEL": "Texture 9",  "TYPE": "image" },
        { "NAME": "t9",  "LABEL": "Texture 10", "TYPE": "image" },
        { "NAME": "t10", "LABEL": "Texture 11", "TYPE": "image" },
        { "NAME": "t11", "LABEL": "Texture 12", "TYPE": "image" },
        { "NAME": "t12", "LABEL": "Texture 13", "TYPE": "image" },
        { "NAME": "t13", "LABEL": "Texture 14", "TYPE": "image" },
        { "NAME": "t14", "LABEL": "Texture 15", "TYPE": "image" },
        { "NAME": "t15", "LABEL": "Texture 16", "TYPE": "image" },
        {
            "NAME": "arrangement",
            "LABEL": "Layout",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [0, 1, 2],
            "LABELS": ["Grid", "Row", "Column"]
        },
        {
            "NAME": "count",
            "LABEL": "Input Count",
            "TYPE": "long",
            "DEFAULT": 4,
            "VALUES": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
        },
        {
            "NAME": "gap",
            "LABEL": "Gap",
            "TYPE": "float",
            "DEFAULT": 0.005,
            "MIN": 0.0,
            "MAX": 0.05
        },
        {
            "NAME": "bgColor",
            "LABEL": "Background",
            "TYPE": "color",
            "DEFAULT": [0.1, 0.1, 0.1, 1.0]
        }
    ]
}*/

vec4 sampleTexture(int idx, vec2 uv) {
    switch(idx) {
        case 0:  return IMG_NORM_PIXEL(t0, uv);
        case 1:  return IMG_NORM_PIXEL(t1, uv);
        case 2:  return IMG_NORM_PIXEL(t2, uv);
        case 3:  return IMG_NORM_PIXEL(t3, uv);
        case 4:  return IMG_NORM_PIXEL(t4, uv);
        case 5:  return IMG_NORM_PIXEL(t5, uv);
        case 6:  return IMG_NORM_PIXEL(t6, uv);
        case 7:  return IMG_NORM_PIXEL(t7, uv);
        case 8:  return IMG_NORM_PIXEL(t8, uv);
        case 9:  return IMG_NORM_PIXEL(t9, uv);
        case 10: return IMG_NORM_PIXEL(t10, uv);
        case 11: return IMG_NORM_PIXEL(t11, uv);
        case 12: return IMG_NORM_PIXEL(t12, uv);
        case 13: return IMG_NORM_PIXEL(t13, uv);
        case 14: return IMG_NORM_PIXEL(t14, uv);
        case 15: return IMG_NORM_PIXEL(t15, uv);
        default: return bgColor;
    }
}

void main() {
    vec2 uv = isf_FragNormCoord;
    int n = int(count);

    int mode = int(arrangement);

    // Grid dimensions based on layout mode
    int cols, rows;
    if (mode == 1) {
        // Row: all side by side horizontally
        cols = n; rows = 1;
    } else if (mode == 2) {
        // Column: all stacked vertically
        cols = 1; rows = n;
    } else {
        // Grid: as square as possible
        if      (n <= 1)  { cols = 1; rows = 1; }
        else if (n <= 2)  { cols = 2; rows = 1; }
        else if (n <= 4)  { cols = 2; rows = 2; }
        else if (n <= 6)  { cols = 3; rows = 2; }
        else if (n <= 9)  { cols = 3; rows = 3; }
        else if (n <= 12) { cols = 4; rows = 3; }
        else              { cols = 4; rows = 4; }
    }

    // Flip Y so row 0 is at the top (reading order: left-to-right, top-to-bottom)
    float flippedY = 1.0 - uv.y;

    // Determine which cell we're in
    int col = int(floor(uv.x * float(cols)));
    int row = int(floor(flippedY * float(rows)));

    // Clamp to valid range (handles edge at uv = 1.0)
    col = min(col, cols - 1);
    row = min(row, rows - 1);

    // Texture index in reading order
    int idx = row * cols + col;

    // Beyond the active count: show background
    if (idx >= n) {
        gl_FragColor = bgColor;
        return;
    }

    // Local coordinates within the cell [0..1]
    float localU = fract(uv.x * float(cols));
    float localV = fract(flippedY * float(rows));

    // Gap as border around each cell (in cell-local coordinates)
    float gapU = gap * float(cols) * 0.5;
    float gapV = gap * float(rows) * 0.5;

    if (localU < gapU || localU > 1.0 - gapU ||
        localV < gapV || localV > 1.0 - gapV) {
        gl_FragColor = bgColor;
        return;
    }

    // Remap to [0..1] excluding gap, flip V back for correct texture orientation
    vec2 cellUV = vec2(
        (localU - gapU) / (1.0 - 2.0 * gapU),
        1.0 - (localV - gapV) / (1.0 - 2.0 * gapV)
    );

    gl_FragColor = sampleTexture(idx, cellUV);
}
