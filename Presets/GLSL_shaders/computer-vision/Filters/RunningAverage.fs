/*{
  "DESCRIPTION": "Leaky/IIR running average (exponential moving average): out = mix(prev, in, rate), i.e. out += rate * (in - out). The classic adaptive-background / slit-scan primitive. Wire this node's 'Out' back into 'prev' (feedback) so each frame updates the accumulated average. Higher 'rate' tracks the input faster; lower 'rate' is smoother and slower. cv.jit.ravg equivalent. PRECISION: the running state MUST be carried at float precision -- on an 8-bit (rgba8) feedback texture, rate*(cur-avg) < 1/255 rounds to 0 at low rate and the average freezes (dead-band). The single render pass is therefore declared FLOAT (RGBA32F) so sub-1/255 increments accumulate. The feedback edge wired into 'prev' must carry this float target (it does, since 'Out' is the float pass output).",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "CATEGORIES": ["Computer Vision", "Image Processing", "Feedback"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "prev",       "TYPE": "image" },
    { "NAME": "rate",       "TYPE": "float", "DEFAULT": 0.05, "MIN": 0.0, "MAX": 1.0 }
  ],
  "PASSES": [
    { "FLOAT": true }
  ]
}*/

void main()
{
  vec2 uv = isf_FragNormCoord;

  vec3 cur = IMG_NORM_PIXEL(inputImage, uv).rgb;
  vec3 avg = IMG_NORM_PIXEL(prev, uv).rgb;

  // Exponential moving average: avg += rate * (cur - avg).
  vec3 newAvg = mix(avg, cur, rate);

  gl_FragColor = vec4(newAvg, 1.0);
}
