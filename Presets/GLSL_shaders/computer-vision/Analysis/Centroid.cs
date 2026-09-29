/*{
  "DESCRIPTION": "Image centroid + mass via GPU reduction into an SSBO. Accumulates the first moments of luminance (sum w, sum x*w, sum y*w) with atomics, read back via BufferToArray (layout {sumW, sumXW, sumYW, count, sumWHi, sumXWHi, sumYWHi}). Each weighted sum is a 64-bit (hi:lo) total -> host folds sumW = sumW + sumWHi*2^32 (etc.) so the accumulators never overflow uint32 on 8K/tiled/supersampled frames (a bare uint32 would wrap above ~16.8M px). Host derives centroid = (sumXW/sumW, sumYW/sumW) normalized to [0,1], mass = sumW/255. The 'average position of brightness/motion' — a core interaction primitive (cv.jit.centroids).",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": ["Computer Vision", "Analysis"],
  "RESOURCES": [
    { "NAME": "inputTex", "TYPE": "texture" },
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
        { "NAME": "sumW",    "TYPE": "uint" },
        { "NAME": "sumXW",   "TYPE": "uint" },
        { "NAME": "sumYW",   "TYPE": "uint" },
        { "NAME": "count",   "TYPE": "uint" },
        { "NAME": "sumWHi",  "TYPE": "uint" },
        { "NAME": "sumXWHi", "TYPE": "uint" },
        { "NAME": "sumYWHi", "TYPE": "uint" }
      ]
    }
  ],
  "PASSES": [
    { "LOCAL_SIZE": [1, 1, 1],   "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [1, 1, 1] } },
    { "LOCAL_SIZE": [16, 16, 1], "EXECUTION_MODEL": { "TYPE": "2D_IMAGE" } }
  ]
}*/

// Fixed-point weight: luminance in [0,1] -> integer steps so atomicAdd(uint) works.
// Position moments use NORMALISED coords in [0,1] scaled the same way, so sums stay bounded
// for large images (each pixel contributes <= W to each accumulator).
const float W_SCALE = 255.0;

// OVERFLOW (64-bit hi/lo accumulation):
//   Each pixel adds up to W_SCALE (255) into sumW (and <= that into sumXW/sumYW since
//   x,y in [0,1]). A bare uint32 overflows at 255 * Npx > 2^32 (~16.8M px), failing at
//   8K / tiled / supersampled frames. Each of the three weighted sums therefore carries a
//   64-bit total as a (hi:lo) pair: atomicAdd into the low word, inspect the returned
//   previous value, and atomicAdd 1 into the hi word on unsigned wrap. The host
//   reconstructs total = hi * 2^32 + lo, pushing the safe ceiling past any real frame.
//   BACK-COMPAT: the low words (sumW, sumXW, sumYW, count) keep indices 0..3, so a host
//   reading only the low words still decodes correctly below the 16.8M-px ceiling.

void main()
{
  if(PASSINDEX == 0)
  {
    buf.sumW = 0u; buf.sumXW = 0u; buf.sumYW = 0u; buf.count = 0u;
    buf.sumWHi = 0u; buf.sumXWHi = 0u; buf.sumYWHi = 0u;
    return;
  }

  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(outputImage);
  if(pos.x >= size.x || pos.y >= size.y)
    return;

  vec2 uv = (vec2(pos) + 0.5) / vec2(size);
  vec3 rgb = texture(inputTex, uv).rgb;
  float luma = dot(rgb, vec3(0.299, 0.587, 0.114));

  uint w = uint(luma * W_SCALE + 0.5);
  // Normalised position weighted by w, also fixed-point.
  uint xw = uint(luma * uv.x * W_SCALE + 0.5);
  uint yw = uint(luma * uv.y * W_SCALE + 0.5);

  uint pw = atomicAdd(buf.sumW, w);
  if(pw + w < pw) atomicAdd(buf.sumWHi, 1u);
  uint pxw = atomicAdd(buf.sumXW, xw);
  if(pxw + xw < pxw) atomicAdd(buf.sumXWHi, 1u);
  uint pyw = atomicAdd(buf.sumYW, yw);
  if(pyw + yw < pyw) atomicAdd(buf.sumYWHi, 1u);
  atomicAdd(buf.count, 1u);

  imageStore(outputImage, pos, vec4(vec3(luma), 1.0));
}
