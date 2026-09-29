/*{
  "DESCRIPTION": "Grayscale/binary morphology: erode, dilate, open, close over a square or cross structuring element. cv.jit.erode / cv.jit.dilate equivalent. Open/close are done as two passes.",
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "CATEGORIES": ["Computer Vision", "Image Processing"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    {
      "NAME": "operation",
      "TYPE": "long",
      "DEFAULT": 1,
      "VALUES": [0, 1, 2, 3],
      "LABELS": ["Erode", "Dilate", "Open", "Close"]
    },
    { "NAME": "radius", "TYPE": "float", "DEFAULT": 1.0, "MIN": 1.0, "MAX": 16.0 },
    {
      "NAME": "shape",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [0, 1],
      "LABELS": ["Square", "Cross"]
    }
  ],
  "PASSES": [
    { "TARGET": "pass0" },
    {}
  ]
}*/

// Open  = erode then dilate ; Close = dilate then erode.
// Pass 0 runs the first morphological op, pass 1 the second (identity for plain erode/dilate).

// Returns true for erosion in this pass (min), false for dilation (max).
bool erodeThisPass()
{
  if(operation == 0) return true;            // Erode
  if(operation == 1) return false;           // Dilate
  if(operation == 2) return (PASSINDEX == 0); // Open: erode, then dilate
  return (PASSINDEX == 1);                    // Close: dilate, then erode
}

bool secondPassActive()
{
  // Plain erode/dilate are done in pass 0; pass 1 is a passthrough for them.
  return operation == 2 || operation == 3;
}

vec3 sampleSrc(vec2 uv)
{
  if(PASSINDEX == 0)
    return IMG_NORM_PIXEL(inputImage, uv).rgb;
  else
    return IMG_NORM_PIXEL(pass0, uv).rgb;
}

void main()
{
  vec2 uv = isf_FragNormCoord;
  vec2 texel = vec2(1.0) / RENDERSIZE;

  if(PASSINDEX == 1 && !secondPassActive())
  {
    gl_FragColor = vec4(sampleSrc(uv), 1.0);
    return;
  }

  bool doErode = erodeThisPass();
  int r = int(radius);

  vec3 acc = sampleSrc(uv);
  for(int dy = -r; dy <= r; ++dy)
  {
    for(int dx = -r; dx <= r; ++dx)
    {
      if(shape == 1 && dx != 0 && dy != 0)
        continue; // cross: skip diagonal taps

      vec3 s = sampleSrc(uv + vec2(float(dx), float(dy)) * texel);
      acc = doErode ? min(acc, s) : max(acc, s);
    }
  }

  gl_FragColor = vec4(acc, 1.0);
}
