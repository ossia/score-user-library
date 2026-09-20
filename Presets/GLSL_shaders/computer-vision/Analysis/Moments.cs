/*{
  "DESCRIPTION": "Raw image moments up to 3rd order (m00,m10,m01,m11,m20,m02,m30,m21,m12,m03) of luminance via GPU reduction into an SSBO. Pair with MomentsReadback to get centroid, orientation, eccentricity and the full 7 Hu invariants on the host. cv.jit.moments. Positions normalised to [0,1]; fixed-point uint accumulation. The 3rd-order accumulators are scaled by an extra M3_SCALE (256) so tiny x^3/y^3 contributions don't quantise to 0 (Hu[2..6] depend on them); MomentsReadback divides it back out. Every moment carries a 64-bit (hi:lo) pair (low words m00..m03,w,h at indices 0..11; high words m00Hi..m03Hi at 12..21) so the accumulators never overflow uint32 on 8K/tiled/supersampled frames (a bare uint32 would wrap above ~16.8M px).",
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
        { "NAME": "m00", "TYPE": "uint" },
        { "NAME": "m10", "TYPE": "uint" },
        { "NAME": "m01", "TYPE": "uint" },
        { "NAME": "m11", "TYPE": "uint" },
        { "NAME": "m20", "TYPE": "uint" },
        { "NAME": "m02", "TYPE": "uint" },
        { "NAME": "m30", "TYPE": "uint" },
        { "NAME": "m21", "TYPE": "uint" },
        { "NAME": "m12", "TYPE": "uint" },
        { "NAME": "m03", "TYPE": "uint" },
        { "NAME": "w",   "TYPE": "uint" },
        { "NAME": "h",   "TYPE": "uint" },
        { "NAME": "m00Hi", "TYPE": "uint" },
        { "NAME": "m10Hi", "TYPE": "uint" },
        { "NAME": "m01Hi", "TYPE": "uint" },
        { "NAME": "m11Hi", "TYPE": "uint" },
        { "NAME": "m20Hi", "TYPE": "uint" },
        { "NAME": "m02Hi", "TYPE": "uint" },
        { "NAME": "m30Hi", "TYPE": "uint" },
        { "NAME": "m21Hi", "TYPE": "uint" },
        { "NAME": "m12Hi", "TYPE": "uint" },
        { "NAME": "m03Hi", "TYPE": "uint" }
      ]
    }
  ],
  "PASSES": [
    { "LOCAL_SIZE": [1, 1, 1],   "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [1, 1, 1] } },
    { "LOCAL_SIZE": [16, 16, 1], "EXECUTION_MODEL": { "TYPE": "2D_IMAGE" } }
  ]
}*/

// To keep raw moments within uint32, normalise positions to [0,1] and weight by 8-bit luma.
// m20/m02/m11 then stay <= m00. The host un-normalises using stored image w,h.
//
// 3rd-ORDER QUANTIZATION FIX:
//   In normalised coords x,y in [0,1] the 3rd-order terms x^3 etc. get tiny: for x~0.1,
//   W*x^3 ~ 0.25 and uint(...+0.5) collapses to 0, so m30/m21/m12/m03 (hence Hu[2..6])
//   were corrupted. We therefore scale ONLY the 3rd-order accumulators by an extra
//   M3_SCALE so sub-unit contributions survive quantisation. x^3<=1 keeps each
//   contribution <= W*M3_SCALE, well within the 64-bit accumulator below. The host
//   divides m30/m21/m12/m03 by M3_SCALE before forming central moments / Hu.
//
// OVERFLOW (64-bit hi/lo accumulation):
//   Each accumulator can exceed uint32 above ~16.8M px (the 3rd-order ones sooner because
//   of M3_SCALE). Every moment therefore carries a 64-bit (hi:lo) pair: atomicAdd into the
//   low word, then atomicAdd 1 into the hi word on unsigned wrap. The host reconstructs
//   lo + hi*2^32. BACK-COMPAT: the 12 original fields (m00..m03, w, h) keep indices 0..11,
//   so a host reading only the low words still decodes correctly below the 16.8M-px ceiling
//   and with M3_SCALE==1 semantics if it ignores the scale (the readback handles both).

const float M3_SCALE = 256.0; // extra fixed-point gain for 3rd-order moments

void main()
{
  if(PASSINDEX == 0)
  {
    buf.m00 = 0u; buf.m10 = 0u; buf.m01 = 0u;
    buf.m11 = 0u; buf.m20 = 0u; buf.m02 = 0u;
    buf.m30 = 0u; buf.m21 = 0u; buf.m12 = 0u; buf.m03 = 0u;
    buf.w = 0u; buf.h = 0u;
    buf.m00Hi = 0u; buf.m10Hi = 0u; buf.m01Hi = 0u;
    buf.m11Hi = 0u; buf.m20Hi = 0u; buf.m02Hi = 0u;
    buf.m30Hi = 0u; buf.m21Hi = 0u; buf.m12Hi = 0u; buf.m03Hi = 0u;
    return;
  }

  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(outputImage);
  if(pos.x >= size.x || pos.y >= size.y)
    return;

  if(pos == ivec2(0, 0))
  {
    buf.w = uint(size.x);
    buf.h = uint(size.y);
  }

  vec2 uv = (vec2(pos) + 0.5) / vec2(size);
  vec3 rgb = texture(inputTex, uv).rgb;
  float I = dot(rgb, vec3(0.299, 0.587, 0.114)); // weight in [0,1]

  float W = I * 255.0;
  float x = uv.x, y = uv.y;

  // 64-bit accumulation: atomicAdd the low word, carry into the hi word on unsigned wrap.
  uint a; uint p;
  a = uint(W + 0.5);                     p = atomicAdd(buf.m00, a); if(p + a < p) atomicAdd(buf.m00Hi, 1u);
  a = uint(W * x + 0.5);                 p = atomicAdd(buf.m10, a); if(p + a < p) atomicAdd(buf.m10Hi, 1u);
  a = uint(W * y + 0.5);                 p = atomicAdd(buf.m01, a); if(p + a < p) atomicAdd(buf.m01Hi, 1u);
  a = uint(W * x * y + 0.5);             p = atomicAdd(buf.m11, a); if(p + a < p) atomicAdd(buf.m11Hi, 1u);
  a = uint(W * x * x + 0.5);             p = atomicAdd(buf.m20, a); if(p + a < p) atomicAdd(buf.m20Hi, 1u);
  a = uint(W * y * y + 0.5);             p = atomicAdd(buf.m02, a); if(p + a < p) atomicAdd(buf.m02Hi, 1u);
  // 3rd-order: scaled by M3_SCALE to retain precision (host divides it back out).
  a = uint(W * x * x * x * M3_SCALE + 0.5); p = atomicAdd(buf.m30, a); if(p + a < p) atomicAdd(buf.m30Hi, 1u);
  a = uint(W * x * x * y * M3_SCALE + 0.5); p = atomicAdd(buf.m21, a); if(p + a < p) atomicAdd(buf.m21Hi, 1u);
  a = uint(W * x * y * y * M3_SCALE + 0.5); p = atomicAdd(buf.m12, a); if(p + a < p) atomicAdd(buf.m12Hi, 1u);
  a = uint(W * y * y * y * M3_SCALE + 0.5); p = atomicAdd(buf.m03, a); if(p + a < p) atomicAdd(buf.m03Hi, 1u);

  imageStore(outputImage, pos, vec4(vec3(I), 1.0));
}
