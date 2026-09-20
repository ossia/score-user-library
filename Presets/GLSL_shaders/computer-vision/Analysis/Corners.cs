/*{
  "DESCRIPTION": "Harris corner detector entirely on the GPU: per-pixel Harris response, 3x3 non-maximum suppression, then atomic-append of surviving corners into a fixed-capacity point SSBO. Read back with BufferToArray (Float32/FloatArray): [count, x0,y0, x1,y1, ...] with normalised coords. cv.jit.features (Shi-Tomasi/Harris). Cap via 'maxCorners' (overflow is clamped).",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": ["Computer Vision", "Analysis"],
  "RESOURCES": [
    { "NAME": "inputTex", "TYPE": "texture" },
    { "NAME": "k",         "TYPE": "float", "DEFAULT": 0.04, "MIN": 0.01, "MAX": 0.2 },
    { "NAME": "threshold", "TYPE": "float", "DEFAULT": 0.01, "MIN": 0.0,  "MAX": 0.5 },
    { "NAME": "maxCorners","TYPE": "long",  "DEFAULT": 1024, "MIN": 16,   "MAX": 8192 },
    {
      "NAME": "outputImage",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba8",
      "WIDTH": "$WIDTH_inputTex",
      "HEIGHT": "$HEIGHT_inputTex"
    },
    {
      "NAME": "buf",
      "TYPE": "storage",
      "ACCESS": "read_write",
      "LAYOUT": [
        { "NAME": "count",  "TYPE": "uint" },
        { "NAME": "coords", "TYPE": "float[16384]" }
      ]
    }
  ],
  "PASSES": [
    { "LOCAL_SIZE": [1, 1, 1],   "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [1, 1, 1] } },
    { "LOCAL_SIZE": [16, 16, 1], "EXECUTION_MODEL": { "TYPE": "2D_IMAGE" } }
  ]
}*/

float luma(vec2 uv)
{
  return dot(texture(inputTex, uv).rgb, vec3(0.299, 0.587, 0.114));
}

// Harris response at the given pixel using a 3x3 gradient window.
float harris(ivec2 p, ivec2 size)
{
  vec2 t = 1.0 / vec2(size);
  vec2 uv = (vec2(p) + 0.5) * t;

  float Sxx = 0.0, Syy = 0.0, Sxy = 0.0;
  for(int dy = -1; dy <= 1; ++dy)
  {
    for(int dx = -1; dx <= 1; ++dx)
    {
      vec2 c = uv + vec2(dx, dy) * t;
      float gx = luma(c + vec2(t.x, 0.0)) - luma(c - vec2(t.x, 0.0));
      float gy = luma(c + vec2(0.0, t.y)) - luma(c - vec2(0.0, t.y));
      Sxx += gx * gx;
      Syy += gy * gy;
      Sxy += gx * gy;
    }
  }
  float det = Sxx * Syy - Sxy * Sxy;
  float trace = Sxx + Syy;
  return det - k * trace * trace;
}

void main()
{
  if(PASSINDEX == 0)
  {
    buf.count = 0u;
    return;
  }

  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(outputImage);
  if(pos.x >= size.x || pos.y >= size.y)
    return;

  float r = harris(pos, size);

  // Visualise the response.
  imageStore(outputImage, pos, vec4(vec3(clamp(r * 8.0, 0.0, 1.0)), 1.0));

  if(r < threshold)
    return;
  if(pos.x < 1 || pos.y < 1 || pos.x >= size.x - 1 || pos.y >= size.y - 1)
    return;

  // 3x3 non-maximum suppression.
  bool isMax = true;
  for(int dy = -1; dy <= 1 && isMax; ++dy)
    for(int dx = -1; dx <= 1; ++dx)
    {
      if(dx == 0 && dy == 0)
        continue;
      if(harris(pos + ivec2(dx, dy), size) > r)
      {
        isMax = false;
        break;
      }
    }
  if(!isMax)
    return;

  uint cap = uint(maxCorners);
  uint idx = atomicAdd(buf.count, 1u);
  if(idx >= cap || (idx * 2u + 1u) >= 16384u)
    return; // clamp on overflow

  vec2 uv = (vec2(pos) + 0.5) / vec2(size);
  buf.coords[idx * 2u]      = uv.x;
  buf.coords[idx * 2u + 1u] = uv.y;
}
