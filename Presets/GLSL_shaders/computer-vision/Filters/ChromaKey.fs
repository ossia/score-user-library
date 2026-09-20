/*{
  "DESCRIPTION": "HSV chroma key / color-range mask. Keys pixels within hue/saturation/value tolerance of a target color, with soft edges. Outputs either the keyed image (alpha cut) or a binary mask. cv.jit inRange / color-tracking front-end. LOW-SATURATION HUE GUARD: near-gray pixels (low saturation) have an ill-defined, noisy hue, so matching them on hue produces speckle. When EITHER the pixel's or the key color's saturation is below 'satGuard', the hue test is bypassed (treated as a hue match) and the result relies on the saturation+value tests instead -- this keeps gray/white/black regions from flickering in/out of the key. Set satGuard to 0 to disable the guard (always test hue).",
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "CATEGORIES": ["Computer Vision", "Image Processing"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "keyColor",   "TYPE": "color", "DEFAULT": [0.0, 1.0, 0.0, 1.0] },
    { "NAME": "hueTol",     "TYPE": "float", "DEFAULT": 0.08, "MIN": 0.0, "MAX": 0.5 },
    { "NAME": "satTol",     "TYPE": "float", "DEFAULT": 0.3,  "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "valTol",     "TYPE": "float", "DEFAULT": 0.3,  "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "softness",   "TYPE": "float", "DEFAULT": 0.05, "MIN": 0.0, "MAX": 0.5 },
    { "NAME": "satGuard",   "TYPE": "float", "DEFAULT": 0.15, "MIN": 0.0, "MAX": 1.0 },
    {
      "NAME": "output",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [0, 1, 2],
      "LABELS": ["Mask", "Keyed (cut matched)", "Keyed (keep matched)"]
    }
  ]
}*/

vec3 rgb2hsv(vec3 c)
{
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float hueDist(float a, float b)
{
  float d = abs(a - b);
  return min(d, 1.0 - d); // hue is circular
}

void main()
{
  vec2 uv = isf_FragNormCoord;
  vec4 src = IMG_NORM_PIXEL(inputImage, uv);

  vec3 hsv = rgb2hsv(src.rgb);
  vec3 key = rgb2hsv(keyColor.rgb);

  // Per-channel soft membership; the pixel matches only if all three pass.
  float h = 1.0 - smoothstep(hueTol, hueTol + softness, hueDist(hsv.x, key.x));
  float s = 1.0 - smoothstep(satTol, satTol + softness, abs(hsv.y - key.y));
  float v = 1.0 - smoothstep(valTol, valTol + softness, abs(hsv.z - key.z));

  // Low-saturation hue guard: hue is unstable for near-gray pixels (and for a near-gray
  // key color), so when either saturation is below satGuard we skip the hue test (h = 1)
  // and let saturation + value decide. Avoids speckle on white/gray/black regions.
  if(min(hsv.y, key.y) < satGuard)
    h = 1.0;

  float match = h * s * v;

  if(output == 0)
  {
    gl_FragColor = vec4(vec3(match), 1.0);
  }
  else if(output == 1)
  {
    // Cut matched pixels (green-screen removal).
    gl_FragColor = vec4(src.rgb, src.a * (1.0 - match));
  }
  else
  {
    // Keep only matched pixels.
    gl_FragColor = vec4(src.rgb, src.a * match);
  }
}
