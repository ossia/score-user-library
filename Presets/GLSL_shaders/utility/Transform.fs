/*{
  "ISFVSN": "2",
  "CATEGORIES": ["Geometry Adjustment"],
  "CREDIT": "ossia score",
  "DESCRIPTION": "2D image transform with translate, rotate, scale, pivot, tiling, and edge extend modes.",
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "NAME": "transformOrder",
      "TYPE": "long",
      "LABEL": "Transform Order",
      "VALUES": [0, 1, 2, 3, 4, 5],
      "LABELS": ["SRT", "STR", "RST", "RTS", "TSR", "TRS"],
      "DEFAULT": 0
    },
    {
      "NAME": "translate",
      "TYPE": "point2D",
      "LABEL": "Translate",
      "DEFAULT": [0.0, 0.0],
      "MIN": [-2.0, -2.0],
      "MAX": [2.0, 2.0]
    },
    {
      "NAME": "rotateAngle",
      "TYPE": "float",
      "LABEL": "Rotate",
      "DEFAULT": 0.0,
      "MIN": -360.0,
      "MAX": 360.0
    },
    {
      "NAME": "scaleAmount",
      "TYPE": "point2D",
      "LABEL": "Scale",
      "DEFAULT": [1.0, 1.0],
      "MIN": [0.01, 0.01],
      "MAX": [10.0, 10.0]
    },
    {
      "NAME": "growShrink",
      "TYPE": "point2D",
      "LABEL": "Grow / Shrink (px)",
      "DEFAULT": [0.0, 0.0],
      "MIN": [-1000.0, -1000.0],
      "MAX": [1000.0, 1000.0]
    },
    {
      "NAME": "pivot",
      "TYPE": "point2D",
      "LABEL": "Pivot",
      "DEFAULT": [0.5, 0.5],
      "MIN": [-1.0, -1.0],
      "MAX": [2.0, 2.0]
    },
    {
      "NAME": "bgColor",
      "TYPE": "color",
      "LABEL": "Background Color",
      "DEFAULT": [0.0, 0.0, 0.0, 0.0]
    },
    {
      "NAME": "premultRGBbyAlpha",
      "TYPE": "bool",
      "LABEL": "Pre-Multiply RGB by Alpha",
      "DEFAULT": false
    },
    {
      "NAME": "compOverBg",
      "TYPE": "bool",
      "LABEL": "Comp Over Background",
      "DEFAULT": false
    },
    {
      "NAME": "extend",
      "TYPE": "long",
      "LABEL": "Extend Mode",
      "VALUES": [0, 1, 2, 3],
      "LABELS": ["Hold", "Zero", "Repeat", "Mirror"],
      "DEFAULT": 1
    },
    {
      "NAME": "limitTiles",
      "TYPE": "bool",
      "LABEL": "Limit Tiles",
      "DEFAULT": false
    },
    {
      "NAME": "tileU",
      "TYPE": "point2D",
      "LABEL": "Tile U (Left, Right)",
      "DEFAULT": [1.0, 1.0],
      "MIN": [0.0, 0.0],
      "MAX": [20.0, 20.0]
    },
    {
      "NAME": "tileV",
      "TYPE": "point2D",
      "LABEL": "Tile V (Bottom, Top)",
      "DEFAULT": [1.0, 1.0],
      "MIN": [0.0, 0.0],
      "MAX": [20.0, 20.0]
    }
  ]
}*/

const float PI = 3.14159265359;

mat3 tr(vec2 t) {
    return mat3(
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        t.x, t.y, 1.0
    );
}

mat3 rot(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat3(
         c,  s, 0.0,
        -s,  c, 0.0,
       0.0, 0.0, 1.0
    );
}

mat3 sc(vec2 s) {
    return mat3(
        s.x, 0.0, 0.0,
        0.0, s.y, 0.0,
        0.0, 0.0, 1.0
    );
}

void main() {
    vec2 uv = isf_FragNormCoord;

    // Effective scale: combine user scale with grow/shrink (pixel offset)
    vec2 effScale = scaleAmount;
    if (growShrink.x != 0.0 || growShrink.y != 0.0) {
        effScale *= (RENDERSIZE + 2.0 * growShrink) / RENDERSIZE;
    }
    effScale = max(effScale, vec2(0.001));

    float angle = rotateAngle * PI / 180.0;

    // Inverse transform components
    mat3 inv_T = tr(-translate);
    mat3 inv_R = tr(pivot) * rot(-angle) * tr(-pivot);
    mat3 inv_S = tr(pivot) * sc(1.0 / effScale) * tr(-pivot);

    // Build composite inverse matrix.
    // Transform order names describe the forward application order
    // (e.g. SRT = Scale first, then Rotate, then Translate).
    // Forward: M = last * ... * first
    // Inverse: M^-1 = first^-1 * ... * last^-1
    mat3 invM;

    if (transformOrder == 0)       // SRT -> fwd T*R*S -> inv S^-1*R^-1*T^-1
        invM = inv_S * inv_R * inv_T;
    else if (transformOrder == 1)  // STR -> fwd R*T*S -> inv S^-1*T^-1*R^-1
        invM = inv_S * inv_T * inv_R;
    else if (transformOrder == 2)  // RST -> fwd T*S*R -> inv R^-1*S^-1*T^-1
        invM = inv_R * inv_S * inv_T;
    else if (transformOrder == 3)  // RTS -> fwd S*T*R -> inv R^-1*T^-1*S^-1
        invM = inv_R * inv_T * inv_S;
    else if (transformOrder == 4)  // TSR -> fwd R*S*T -> inv T^-1*S^-1*R^-1
        invM = inv_T * inv_S * inv_R;
    else                           // TRS -> fwd S*R*T -> inv T^-1*R^-1*S^-1
        invM = inv_T * inv_R * inv_S;

    // Map output UV to source UV
    vec2 srcUV = (invM * vec3(uv, 1.0)).xy;

    // Prepare background color
    vec4 bg = bgColor;
    if (premultRGBbyAlpha) {
        bg.rgb *= bg.a;
    }

    // Tile limit check (only relevant for Repeat / Mirror)
    if (limitTiles && (extend == 2 || extend == 3)) {
        float minU = -tileU.x;
        float maxU = 1.0 + tileU.y;
        float minV = -tileV.x;
        float maxV = 1.0 + tileV.y;

        if (srcUV.x < minU || srcUV.x > maxU ||
            srcUV.y < minV || srcUV.y > maxV) {
            gl_FragColor = bg;
            return;
        }
    }

    // Apply extend mode
    if (extend == 0) {
        // Hold: clamp to edge
        srcUV = clamp(srcUV, vec2(0.0), vec2(1.0));
    }
    else if (extend == 1) {
        // Zero: background for out-of-bounds
        if (srcUV.x < 0.0 || srcUV.x > 1.0 ||
            srcUV.y < 0.0 || srcUV.y > 1.0) {
            gl_FragColor = bg;
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

    // Sample input
    vec4 color = IMG_NORM_PIXEL(inputImage, srcUV);

    // Comp over background
    if (compOverBg && color.a < 1.0) {
        color = vec4(
            color.rgb + bg.rgb * (1.0 - color.a),
            color.a   + bg.a   * (1.0 - color.a)
        );
    }

    gl_FragColor = color;
}
