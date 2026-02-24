/*{
  "ISFVSN": "2",
  "CATEGORIES": ["Geometry Adjustment"],
  "CREDIT": "ossia score",
  "DESCRIPTION": "Crop an image by its left, right, bottom, and top edges. The cropped region is remapped to fill the output",
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "NAME": "cropLeft",
      "TYPE": "float",
      "LABEL": "Crop Left",
      "DEFAULT": 0.0,
      "MIN": -0.5,
      "MAX": 1.5
    },
    {
      "NAME": "cropRight",
      "TYPE": "float",
      "LABEL": "Crop Right",
      "DEFAULT": 1.0,
      "MIN": -0.5,
      "MAX": 1.5
    },
    {
      "NAME": "cropBottom",
      "TYPE": "float",
      "LABEL": "Crop Bottom",
      "DEFAULT": 0.0,
      "MIN": -0.5,
      "MAX": 1.5
    },
    {
      "NAME": "cropTop",
      "TYPE": "float",
      "LABEL": "Crop Top",
      "DEFAULT": 1.0,
      "MIN": -0.5,
      "MAX": 1.5
    },
    {
      "NAME": "extend",
      "TYPE": "long",
      "LABEL": "Extend",
      "VALUES": [0, 1, 2, 3],
      "LABELS": ["Hold", "Zero", "Repeat", "Mirror"],
      "DEFAULT": 0
    }
  ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;

    // Map output [0,1] to the crop region in source space
    vec2 srcUV = vec2(
        mix(cropLeft, cropRight, uv.x),
        mix(cropBottom, cropTop, uv.y)
    );

    // Apply extend mode for source UVs outside [0,1]
    if (extend == 0) {
        // Hold: clamp to image edge
        srcUV = clamp(srcUV, vec2(0.0), vec2(1.0));
    }
    else if (extend == 1) {
        // Zero: transparent black for out-of-bounds
        if (srcUV.x < 0.0 || srcUV.x > 1.0 ||
            srcUV.y < 0.0 || srcUV.y > 1.0) {
            gl_FragColor = vec4(0.0);
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

    gl_FragColor = IMG_NORM_PIXEL(inputImage, srcUV);
}
