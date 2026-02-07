/*{
  "ISFVSN": 2,
  "CATEGORIES": ["Geometry Adjustment"],
  "CREDIT": "Jean-Michaël Celerier",
  "DESCRIPTION": "Crop a normalized rectangle from the input image and stretch it to the output. Two modes: Center+Size or Corners.",
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image",
      "DEFAULT": null
    },
    {
      "NAME": "mode",
      "TYPE": "long",
      "LABEL": "Mode",
      "VALUES": [0, 1],
      "LABELS": ["Center/Size", "Corners"],
      "DEFAULT": 0
    },
    {
      "NAME": "center",
      "TYPE": "point2D",
      "DEFAULT": [0.5, 0.5],
      "MIN": [0.0, 0.0],
      "MAX": [1.0, 1.0]
    },
    {
      "NAME": "width",
      "TYPE": "float",
      "MIN": 0.0,
      "MAX": 1.0,
      "DEFAULT": 0.5
    },
    {
      "NAME": "height",
      "TYPE": "float",
      "MIN": 0.0,
      "MAX": 1.0,
      "DEFAULT": 0.5
    },
    {
      "NAME": "topLeft",
      "TYPE": "point2D",
      "DEFAULT": [0.25, 0.25],
      "MIN": [0.0, 0.0],
      "MAX": [1.0, 1.0]
    },
    {
      "NAME": "bottomRight",
      "TYPE": "point2D",
      "DEFAULT": [0.75, 0.75],
      "MIN": [0.0, 0.0],
      "MAX": [1.0, 1.0]
    },
    {
      "NAME": "bgColor",
      "TYPE": "color",
      "DEFAULT": [0.0, 0.0, 0.0, 1.0]
    }
  ]
}*/

void main() {
    // Normalized fragment coordinate (0..1)
    vec2 uv = isf_FragNormCoord;

    // Compute rectangle in normalized coordinates [0..1]
    vec2 rectMin;
    vec2 rectMax;

    if (mode == 0) {
        // Center + size mode
        vec2 half = vec2(width, height) * 0.5;
        rectMin = center - half;
        rectMax = center + half;
    } else {
        // Corners mode (topLeft, bottomRight)
        rectMin = topLeft;
        rectMax = bottomRight;
    }

    // Clamp, and ensure rectMin <= rectMax
    rectMin = clamp(rectMin, vec2(0.0), vec2(1.0));
    rectMax = clamp(rectMax, vec2(0.0), vec2(1.0));
    vec2 rmin = min(rectMin, rectMax);
    vec2 rmax = max(rectMin, rectMax);

    vec2 rectSize = rmax - rmin;

    // If rect has no area, output background color
    if (rectSize.x <= 1e-6 || rectSize.y <= 1e-6) {
        gl_FragColor = bgColor;
        return;
    }

    // Map output uv (0..1) to the selected rect (rmin..rmax)
    vec2 sampleUV = rmin + uv * rectSize;

    // Sample the input image using normalized coordinates
    // (IMG_NORM_PIXEL is the standard ISF macro for normalized sampling)
    vec4 color = IMG_NORM_PIXEL(inputImage, sampleUV);

    gl_FragColor = color;
}
