/*{
  "DESCRIPTION": "Running temporal mean of the input over many frames (cumulative average). Wire this node's 'Out' back into 'prev' (feedback) to accumulate the mean. A true cv.jit.mean accumulate needs a frame counter we don't have, so this approximates it as a long-time-constant leaky average: the effective rate is 1.0 / max(1.0, window), where 'window' is the averaging window in frames. Larger 'window' converges more slowly toward a stable long-term mean. cv.jit.mean equivalent. PRECISION: the effective rate is 1/window, so at window=60 the per-frame increment is rate*(cur-mean) and falls below 1/255 for small differences; on an 8-bit (rgba8) feedback texture that rounds to 0 and the mean freezes (dead-band). The single render pass is therefore declared FLOAT (RGBA32F) so sub-1/255 increments accumulate. The feedback edge wired into 'prev' must carry this float target.",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "CATEGORIES": ["Computer Vision", "Image Processing", "Feedback"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "prev",       "TYPE": "image" },
    { "NAME": "window",     "TYPE": "float", "DEFAULT": 60.0, "MIN": 1.0, "MAX": 600.0 }
  ],
  "PASSES": [
    { "FLOAT": true }
  ]
}*/

void main()
{
  vec2 uv = isf_FragNormCoord;

  vec3 cur  = IMG_NORM_PIXEL(inputImage, uv).rgb;
  vec3 mean = IMG_NORM_PIXEL(prev, uv).rgb;

  // Convert the averaging window (in frames) to an effective leak rate.
  // Approximates cv.jit.mean's cumulative accumulate over 'window' frames.
  float rate = 1.0 / max(1.0, window);

  vec3 newMean = mix(mean, cur, rate);

  gl_FragColor = vec4(newMean, 1.0);
}
