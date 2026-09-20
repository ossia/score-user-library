/*{
  "DESCRIPTION": "Dense optical flow (single-iteration Horn-Schunck-style) as an image. Encodes per-pixel motion in RG (flow.xy mapped to [0,1], 0.5=zero) and magnitude in B. Wire 'Out' back into 'prev' to provide the previous frame. Use the flow field to drive warps / particle advection. cv.jit dense flow.",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "CATEGORIES": ["Computer Vision", "Image Processing", "Feedback"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "prev",       "TYPE": "image" },
    { "NAME": "scale",      "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 4.0 },
    { "NAME": "smooth",     "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 }
  ]
}*/

float luma(vec4 c)
{
  return dot(c.rgb, vec3(0.299, 0.587, 0.114));
}

void main()
{
  vec2 uv = isf_FragNormCoord;
  vec2 texel = vec2(1.0) / RENDERSIZE;

  // Spatial gradients (central diff) on the current frame.
  float l  = luma(IMG_NORM_PIXEL(inputImage, uv));
  float lx = luma(IMG_NORM_PIXEL(inputImage, uv + vec2(texel.x, 0.0)))
           - luma(IMG_NORM_PIXEL(inputImage, uv - vec2(texel.x, 0.0)));
  float ly = luma(IMG_NORM_PIXEL(inputImage, uv + vec2(0.0, texel.y)))
           - luma(IMG_NORM_PIXEL(inputImage, uv - vec2(0.0, texel.y)));
  // Temporal gradient from the previous frame (prev holds the previous *input*; when fed
  // back from this node's output, the RG carries the prior flow — so we read .a/.b as luma
  // proxies. For best results feed a delayed copy of the input as 'prev').
  float lt = l - luma(IMG_NORM_PIXEL(prev, uv));

  // Optical-flow constraint: lx*u + ly*v + lt = 0. Project onto the gradient direction.
  float g2 = lx * lx + ly * ly + 1e-4;
  vec2 flow = -lt * vec2(lx, ly) / g2;

  // Light smoothing toward the neighbourhood-average flow encoded in prev's RG (if present).
  vec2 prevFlow = IMG_NORM_PIXEL(prev, uv).rg * 2.0 - 1.0;
  flow = mix(flow, prevFlow, smooth * 0.5);

  flow *= scale;

  float mag = length(flow);
  // Encode: RG = flow mapped to [0,1] (0.5 = zero), B = magnitude, A = 1.
  gl_FragColor = vec4(flow * 0.5 + 0.5, clamp(mag, 0.0, 1.0), 1.0);
}
