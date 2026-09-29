/*{
  "DESCRIPTION": "Spatial covariance between the luminance of TWO images, reduced on the GPU into an SSBO and read back via BufferToArray (UInt32/IntArray). For each pixel position it accumulates sum(a), sum(b), sum(a*b) and count over the whole frame, where a,b are the two images' luma at that pixel; the result is the per-pixel spatial covariance of the two images. NOTE: this is NOT cv.jit.covariance (which computes the temporal covariance matrix of a multi-plane signal over time / across cells) -- it is a single scalar spatial covariance between two images. Each sum carries a 64-bit (hi:lo) pair so the uint32 accumulators never overflow, even on 8K/tiled/supersampled frames (a bare uint32 wraps above ~16.8M px). Host-side recovery: let n = count, A = sumA + sumAHi*2^32, B = sumB + sumBHi*2^32, AB = sumAB + sumABHi*2^32; Ea = A/(255*n), Eb = B/(255*n), Eab = AB/(255*n); covariance = Eab - Ea*Eb. sumAB stores 255*(a*b) with a,b in [0,1], so Eab = mean(a*b).",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": ["Computer Vision", "Analysis"],
  "RESOURCES": [
    { "NAME": "inputTexA", "TYPE": "texture" },
    { "NAME": "inputTexB", "TYPE": "texture" },
    {
      "NAME": "outputImage",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba8",
      "WIDTH": "$WIDTH_inputTexA",
      "HEIGHT": "$HEIGHT_inputTexA"
    },
    {
      "NAME": "buf",
      "TYPE": "storage",
      "ACCESS": "read_write",
      "LAYOUT": [
        { "NAME": "sumA",    "TYPE": "uint" },
        { "NAME": "sumB",    "TYPE": "uint" },
        { "NAME": "sumAB",   "TYPE": "uint" },
        { "NAME": "count",   "TYPE": "uint" },
        { "NAME": "sumAHi",  "TYPE": "uint" },
        { "NAME": "sumBHi",  "TYPE": "uint" },
        { "NAME": "sumABHi", "TYPE": "uint" }
      ]
    }
  ],
  "PASSES": [
    { "LOCAL_SIZE": [1, 1, 1],   "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [1, 1, 1] } },
    { "LOCAL_SIZE": [16, 16, 1], "EXECUTION_MODEL": { "TYPE": "2D_IMAGE" } }
  ]
}*/

// The SSBO persists across frames, so pass 0 (a single invocation) clears the accumulators
// before pass 1 (one invocation per output pixel) atomically accumulates the moments.
// Luminances a,b are in [0,1]; ALL three sums use the SAME 8-bit scale (255).
//
// OVERFLOW (64-bit hi/lo accumulation):
//   8.3M (4K) px * 255 ~ 2.1e9 fits uint32, but 8K (~33M px) * 255 ~ 8.5e9 overflows it,
//   and tiled/supersampled frames are worse. Each sum therefore carries a 64-bit (hi:lo)
//   pair: atomicAdd the low word, then atomicAdd 1 into the hi word on unsigned wrap. The
//   host reconstructs lo + hi*2^32 (see DESCRIPTION), pushing the ceiling past any real
//   frame. BACK-COMPAT: the low words keep indices 0..3 (exact below the 16.8M-px ceiling).

const float LUMA_SCALE = 255.0;     // for sum(a), sum(b), AND sum(a*b)
const float PROD_SCALE = 255.0;     // same 8-bit scale

void main()
{
  if(PASSINDEX == 0)
  {
    buf.sumA = 0u;
    buf.sumB = 0u;
    buf.sumAB = 0u;
    buf.count = 0u;
    buf.sumAHi = 0u;
    buf.sumBHi = 0u;
    buf.sumABHi = 0u;
    return;
  }

  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(outputImage);
  if(pos.x >= size.x || pos.y >= size.y)
    return;

  vec2 uv = (vec2(pos) + 0.5) / vec2(size);
  vec3 rgbA = texture(inputTexA, uv).rgb;
  vec3 rgbB = texture(inputTexB, uv).rgb;

  float a = dot(rgbA, vec3(0.299, 0.587, 0.114));
  float b = dot(rgbB, vec3(0.299, 0.587, 0.114));

  uint addA = uint(a * LUMA_SCALE + 0.5);
  uint pA = atomicAdd(buf.sumA, addA);   if(pA + addA < pA) atomicAdd(buf.sumAHi, 1u);
  uint addB = uint(b * LUMA_SCALE + 0.5);
  uint pB = atomicAdd(buf.sumB, addB);   if(pB + addB < pB) atomicAdd(buf.sumBHi, 1u);
  uint addAB = uint(a * b * PROD_SCALE + 0.5);
  uint pAB = atomicAdd(buf.sumAB, addAB); if(pAB + addAB < pAB) atomicAdd(buf.sumABHi, 1u);
  atomicAdd(buf.count, 1u);

  // Passthrough so the node is visually inspectable: product of the two luminances.
  imageStore(outputImage, pos, vec4(vec3(a * b), 1.0));
}
