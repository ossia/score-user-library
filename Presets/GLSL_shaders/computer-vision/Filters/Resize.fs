/*{
  "DESCRIPTION": "Center-zoom / rescale about the image centre. IMPORTANT: this is NOT a true resample to an arbitrary output W x H -- in ISF the output render target is fixed to this node's render size, so the output dimensions cannot be changed here. It instead resamples the input INTO that fixed-size target: scale > 1 zooms in (magnify about centre), scale < 1 zooms out (minify, input shrinks toward the centre with black borders), with optional separate scaleX/scaleY. To actually change pixel dimensions, set this node's render size. Interpolation: Nearest, Bilinear, or Area. Area is a box-average over the source footprint -- use it when downscaling (scale < 1) to avoid aliasing that single-tap Nearest/Bilinear produce; for upscaling it falls back to bilinear. cv.jit.resize equivalent (center-zoom variant).",
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "CATEGORIES": ["Computer Vision", "Image Processing"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "scale",  "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.05, "MAX": 16.0 },
    { "NAME": "scaleX", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.05, "MAX": 16.0 },
    { "NAME": "scaleY", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.05, "MAX": 16.0 },
    {
      "NAME": "interpolation",
      "TYPE": "long",
      "DEFAULT": 1,
      "VALUES": [0, 1, 2],
      "LABELS": ["Nearest", "Bilinear", "Area"]
    }
  ]
}*/

vec4 sampleNearest(vec2 uv)
{
  vec2 texel = vec2(1.0) / RENDERSIZE;
  // Snap to texel centre.
  vec2 p = (floor(uv * RENDERSIZE) + 0.5) * texel;
  return IMG_NORM_PIXEL(inputImage, p);
}

vec4 sampleBilinear(vec2 uv)
{
  vec2 texel = vec2(1.0) / RENDERSIZE;
  vec2 coord = uv * RENDERSIZE - 0.5;
  vec2 base = floor(coord);
  vec2 f = coord - base;

  vec2 uv00 = (base + 0.5) * texel;
  vec4 c00 = IMG_NORM_PIXEL(inputImage, uv00);
  vec4 c10 = IMG_NORM_PIXEL(inputImage, uv00 + vec2(texel.x, 0.0));
  vec4 c01 = IMG_NORM_PIXEL(inputImage, uv00 + vec2(0.0, texel.y));
  vec4 c11 = IMG_NORM_PIXEL(inputImage, uv00 + texel);

  vec4 top = mix(c00, c10, f.x);
  vec4 bot = mix(c01, c11, f.x);
  return mix(top, bot, f.y);
}

// AREA / box-average sampling for downscaling. When scale < 1 a single output pixel covers
// roughly 1/scale source texels per axis; a single bilinear tap then aliases (drops detail
// between taps). We instead average a small box of bilinear taps spanning that source
// footprint. For upscaling (scale >= 1) the footprint is <= 1 texel so we just fall back to
// bilinear. 's' is the per-axis total scale (footprint in source texels = 1/s).
vec4 sampleArea(vec2 uv, vec2 s)
{
  // Footprint half-size in source texels, clamped so the loop stays bounded/cheap.
  vec2 texel = vec2(1.0) / RENDERSIZE;
  vec2 footprint = clamp(1.0 / max(s, vec2(1e-4)), vec2(1.0), vec2(8.0));
  int rx = int(ceil(footprint.x * 0.5));
  int ry = int(ceil(footprint.y * 0.5));

  vec4 acc = vec4(0.0);
  float wsum = 0.0;
  for(int j = -ry; j <= ry; ++j)
  {
    for(int i = -rx; i <= rx; ++i)
    {
      vec2 p = uv + vec2(float(i), float(j)) * texel;
      // Only average samples that fall inside the source image.
      if(p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0)
        continue;
      acc += sampleBilinear(p);
      wsum += 1.0;
    }
  }
  return (wsum > 0.0) ? acc / wsum : sampleBilinear(uv);
}

void main()
{
  vec2 uv = isf_FragNormCoord;

  // Total per-axis scale. Inverse-map the destination coord around the centre:
  // source = centre + (dest - centre) / scale, so scale > 1 magnifies.
  vec2 s = vec2(scale * scaleX, scale * scaleY);
  vec2 src = (uv - 0.5) / s + 0.5;

  // Outside the source image -> black.
  if(src.x < 0.0 || src.x > 1.0 || src.y < 0.0 || src.y > 1.0)
  {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  if(interpolation == 0)
    gl_FragColor = sampleNearest(src);
  else if(interpolation == 1)
    gl_FragColor = sampleBilinear(src);
  else
    gl_FragColor = sampleArea(src, s); // Area: anti-aliased downscale (bilinear if s >= 1)
}
