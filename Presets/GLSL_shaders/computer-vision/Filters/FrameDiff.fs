/*{
  "DESCRIPTION": "Temporal motion via a leaky running-average background. Wire this node's 'Out' back into 'prev' (feedback) to keep the background model. Output packs the running-average background in RGB (this is what must feed back) and the motion amount in ALPHA, so a single feedback edge carries the model while downstream nodes read motion from .a. cv.jit motion / ravg family. PRECISION: the background is a leaky average bg += rate*(cur-bg); at low rate rate*(cur-bg) < 1/255 rounds to 0 on an 8-bit (rgba8) feedback texture and the background model freezes (dead-band), so motion would be measured against a stale background. The single render pass is therefore declared FLOAT (RGBA32F) so sub-1/255 background increments accumulate. The feedback edge wired into 'prev' must carry this float target (it carries RGB=background + A=motion).",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "CATEGORIES": ["Computer Vision", "Image Processing", "Feedback"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "prev",       "TYPE": "image" },
    { "NAME": "rate",       "TYPE": "float", "DEFAULT": 0.05, "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "threshold",  "TYPE": "float", "DEFAULT": 0.1,  "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "binarize",   "TYPE": "bool",  "DEFAULT": true }
  ],
  "PASSES": [
    { "FLOAT": true }
  ]
}*/

float luminance(vec3 c)
{
  return dot(c, vec3(0.299, 0.587, 0.114));
}

void main()
{
  vec2 uv = isf_FragNormCoord;

  vec3 cur = IMG_NORM_PIXEL(inputImage, uv).rgb;
  vec3 bg  = IMG_NORM_PIXEL(prev, uv).rgb;

  // Leaky running-average background: bg += rate * (cur - bg). This is fed back via RGB.
  vec3 newBg = mix(bg, cur, rate);

  float diff = luminance(abs(cur - bg));
  float motion = binarize ? step(threshold, diff) : diff;

  // RGB = background model (feedback), A = motion (downstream).
  gl_FragColor = vec4(newBg, motion);
}
