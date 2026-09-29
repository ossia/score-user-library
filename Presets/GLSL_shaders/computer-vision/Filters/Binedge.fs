/*{
  "DESCRIPTION": "Boundary pixels of a binary blob. A foreground pixel is kept only if at least one of its 8 neighbours is background; interior pixels are dropped. Expects a (thresholded) binary image; outputs white on the boundary, black elsewhere. cv.jit.binedge equivalent.",
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "CATEGORIES": ["Computer Vision", "Image Processing"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "level",  "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "invert", "TYPE": "bool",  "DEFAULT": false }
  ]
}*/

float luminance(vec4 c)
{
  return dot(c.rgb, vec3(0.299, 0.587, 0.114));
}

// Binary sample: 1.0 for foreground, 0.0 for background.
float binSample(vec2 uv)
{
  float v = step(level, luminance(IMG_NORM_PIXEL(inputImage, uv)));
  if(invert)
    v = 1.0 - v;
  return v;
}

void main()
{
  vec2 uv = isf_FragNormCoord;
  vec2 texel = vec2(1.0) / RENDERSIZE;

  float self = binSample(uv);

  if(self < 0.5)
  {
    // Background stays black.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Foreground: it is a boundary pixel if any of the 8 neighbours is background.
  bool boundary = false;
  for(int dy = -1; dy <= 1; ++dy)
  {
    for(int dx = -1; dx <= 1; ++dx)
    {
      if(dx == 0 && dy == 0)
        continue;
      if(binSample(uv + vec2(float(dx), float(dy)) * texel) < 0.5)
        boundary = true;
    }
  }

  float edge = boundary ? 1.0 : 0.0;
  gl_FragColor = vec4(vec3(edge), 1.0);
}
