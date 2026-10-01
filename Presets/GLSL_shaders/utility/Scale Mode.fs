/*{
  "ISFVSN": "2",
  "CATEGORIES": ["Geometry Adjustment"],
  "CREDIT": "ossia score",
  "DESCRIPTION": "Fit an image into the output with the standard scale modes: stretch, fit (letterbox), fill (crop), fit width / height, original size, scale down, integer scale. Alignment chooses where the image sits (or which part gets cropped).",
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "NAME": "mode",
      "TYPE": "long",
      "LABEL": "Mode",
      "VALUES": [0, 1, 2, 3, 4, 5, 6, 7],
      "LABELS": [
        "Stretch",
        "Fit (Letterbox)",
        "Fill (Crop)",
        "Fit Width",
        "Fit Height",
        "Original Size",
        "Scale Down",
        "Integer Scale"
      ],
      "DEFAULT": 1
    },
    {
      "NAME": "outputWidth",
      "TYPE": "float",
      "LABEL": "Output Width (0 = auto)",
      "DEFAULT": 1920.0,
      "MIN": 0.0,
      "MAX": 8192.0
    },
    {
      "NAME": "outputHeight",
      "TYPE": "float",
      "LABEL": "Output Height (0 = auto)",
      "DEFAULT": 1080.0,
      "MIN": 0.0,
      "MAX": 8192.0
    },
    {
      "NAME": "alignment",
      "TYPE": "point2D",
      "LABEL": "Alignment",
      "DEFAULT": [0.5, 0.5],
      "MIN": [0.0, 0.0],
      "MAX": [1.0, 1.0]
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "LABEL": "Zoom",
      "DEFAULT": 1.0,
      "MIN": 0.01,
      "MAX": 10.0
    },
    {
      "NAME": "extend",
      "TYPE": "long",
      "LABEL": "Extend",
      "VALUES": [0, 1, 2, 3],
      "LABELS": ["Hold", "Zero", "Repeat", "Mirror"],
      "DEFAULT": 1
    },
    {
      "NAME": "bgColor",
      "TYPE": "color",
      "LABEL": "Background Color",
      "DEFAULT": [0.0, 0.0, 0.0, 1.0]
    },
    {
      "NAME": "nearest",
      "TYPE": "bool",
      "LABEL": "Nearest Sampling",
      "DEFAULT": false
    }
  ]
}*/

// The input resolution is read from the texture itself. The output
// resolution comes from the Output Width / Height controls; a value of 0
// falls back to the actual render target size (RENDERSIZE). If the
// controls differ from the real render target, the result is computed for
// the requested resolution and then resampled to the render target, so set
// the node's output resolution to match for pixel-exact results.
//
// Everything is computed in output pixels: the image of size texSize is
// scaled to dispSize, then placed so that `alignment` of the leftover
// space (or of the overflow, when cropping) is on each side.
// With alignment = center this matches score's ScaleMode:
//   Original  -> "Original Size"
//   BlackBars -> "Fit (Letterbox)"
//   Fill      -> "Fill (Crop)"
//   Stretch   -> "Stretch"

void main() {
    vec2 renderSize = vec2(
        outputWidth > 0.0 ? outputWidth : RENDERSIZE.x,
        outputHeight > 0.0 ? outputHeight : RENDERSIZE.y
    );
    vec2 texSize = IMG_SIZE(inputImage);

    if (texSize.x <= 0.0 || texSize.y <= 0.0) {
        gl_FragColor = bgColor;
        return;
    }

    // Per-axis scale factors that make the image match the output
    vec2 ratio = renderSize / texSize;
    float fitScale = min(ratio.x, ratio.y);
    float fillScale = max(ratio.x, ratio.y);

    vec2 dispSize;
    if (mode == 0) {
        // Stretch: ignore aspect ratio
        dispSize = renderSize;
    }
    else if (mode == 1) {
        // Fit / contain: whole image visible, bars on the sides
        dispSize = texSize * fitScale;
    }
    else if (mode == 2) {
        // Fill / cover: output fully covered, image cropped
        dispSize = texSize * fillScale;
    }
    else if (mode == 3) {
        // Fit width: match output width, crop or bar vertically
        dispSize = texSize * ratio.x;
    }
    else if (mode == 4) {
        // Fit height: match output height, crop or bar horizontally
        dispSize = texSize * ratio.y;
    }
    else if (mode == 5) {
        // Original: 1 input pixel = 1 output pixel
        dispSize = texSize;
    }
    else if (mode == 6) {
        // Scale down: like fit, but never enlarge
        dispSize = texSize * min(fitScale, 1.0);
    }
    else {
        // Integer scale: largest whole multiple (or 1/n fraction) that fits
        float k = fitScale >= 1.0 ? floor(fitScale) : 1.0 / ceil(1.0 / fitScale);
        dispSize = texSize * k;
    }

    dispSize *= zoom;

    // Place the image and map the output pixel back to source UV
    vec2 offset = (renderSize - dispSize) * alignment;
    vec2 fragPx = isf_FragNormCoord * renderSize;
    vec2 srcUV = (fragPx - offset) / dispSize;

    // Apply extend mode for source UVs outside [0,1]
    if (extend == 0) {
        // Hold: clamp to image edge
        srcUV = clamp(srcUV, vec2(0.0), vec2(1.0));
    }
    else if (extend == 1) {
        // Zero: background for out-of-bounds
        if (srcUV.x < 0.0 || srcUV.x > 1.0 ||
            srcUV.y < 0.0 || srcUV.y > 1.0) {
            gl_FragColor = bgColor;
            return;
        }
    }
    else if (extend == 2) {
        // Repeat
        srcUV = fract(srcUV);
    }
    else {
        // Mirror: ping-pong
        vec2 m = mod(srcUV, 2.0);
        srcUV = vec2(
            m.x < 1.0 ? m.x : 2.0 - m.x,
            m.y < 1.0 ? m.y : 2.0 - m.y
        );
    }

    // Snap to texel centers for crisp pixel-art / integer scaling
    if (nearest) {
        srcUV = (min(floor(srcUV * texSize), texSize - 1.0) + 0.5) / texSize;
    }

    gl_FragColor = IMG_NORM_PIXEL(inputImage, srcUV);
}
