/*{
  "DESCRIPTION": "Binarize an image. Global (fixed level) or adaptive (local mean - C) thresholding on luminance, with optional inversion. cv.jit.threshold equivalent.",
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "CATEGORIES": ["Computer Vision", "Image Processing"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    {
      "NAME": "mode",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [0, 1],
      "LABELS": ["Global", "Adaptive (mean - C)"]
    },
    { "NAME": "level",  "TYPE": "float", "DEFAULT": 0.5,  "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "radius", "TYPE": "float", "DEFAULT": 4.0,  "MIN": 1.0, "MAX": 32.0 },
    { "NAME": "C",      "TYPE": "float", "DEFAULT": 0.02, "MIN": -0.5, "MAX": 0.5 },
    { "NAME": "invert", "TYPE": "bool",  "DEFAULT": false }
  ]
}*/

float luminance(vec4 c)
{
  return dot(c.rgb, vec3(0.299, 0.587, 0.114));
}

void main()
{
  vec2 uv = isf_FragNormCoord;
  vec2 texel = vec2(1.0) / RENDERSIZE;

  float v = luminance(IMG_NORM_PIXEL(inputImage, uv));
  float thr;

  if(mode == 0)
  {
    thr = level;
  }
  else
  {
    // Local mean over a (2r+1) box, then subtract C.
    int r = int(radius);
    float sum = 0.0;
    float n = 0.0;
    for(int dy = -r; dy <= r; ++dy)
    {
      for(int dx = -r; dx <= r; ++dx)
      {
        sum += luminance(IMG_NORM_PIXEL(inputImage, uv + vec2(float(dx), float(dy)) * texel));
        n += 1.0;
      }
    }
    thr = (sum / n) - C;
  }

  float bin = step(thr, v);
  if(invert)
    bin = 1.0 - bin;

  gl_FragColor = vec4(vec3(bin), 1.0);
}
