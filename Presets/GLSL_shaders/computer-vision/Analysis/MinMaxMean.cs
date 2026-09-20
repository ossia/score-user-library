/*{
  "DESCRIPTION": "Luminance min / max / mean over the image via GPU reduction into an SSBO. Read back with BufferToArray (UInt32 / IntArray) as [lmin, lmax, lsum, count, lsumHi]; host: min=lmin/65535, max=lmax/65535 (16-bit fixed point), mean=(lsum + lsumHi*2^32)/count/255. The sum is 8-bit-scaled and carries a 64-bit (lsumHi:lsum) total so it never overflows uint32 even on 8K/tiled/supersampled frames (a bare uint32 lsum would wrap above ~16.8M px). Drives brightness/exposure -> control mappings.",
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
        { "NAME": "lmin",   "TYPE": "uint" },
        { "NAME": "lmax",   "TYPE": "uint" },
        { "NAME": "lsum",   "TYPE": "uint" },
        { "NAME": "count",  "TYPE": "uint" },
        { "NAME": "lsumHi", "TYPE": "uint" }
      ]
    }
  ],
  "PASSES": [
    { "LOCAL_SIZE": [1, 1, 1],   "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [1, 1, 1] } },
    { "LOCAL_SIZE": [16, 16, 1], "EXECUTION_MODEL": { "TYPE": "2D_IMAGE" } }
  ]
}*/

// 16-bit fixed point for luma so min/max have useful resolution.
const float SCALE = 65535.0;

// OVERFLOW (64-bit hi/lo accumulation for the sum):
//   lsum adds up to 255 per pixel; a bare uint32 overflows at 255 * Npx > 2^32 (~16.8M px).
//   We carry a 64-bit total as (lsumHi:lsum): atomicAdd the low word, then atomicAdd 1 into
//   the hi word on unsigned wrap. Host mean = (lsum + lsumHi*2^32) / count / 255. min/max are
//   bounded by SCALE so they never overflow. BACK-COMPAT: lsum stays at index 2 (host that
//   ignores lsumHi is exact below the 16.8M-px ceiling).
const float SUM_SCALE = 255.0;

void main()
{
  if(PASSINDEX == 0)
  {
    buf.lmin = 0xFFFFFFFFu; // +inf for atomicMin
    buf.lmax = 0u;          // -inf for atomicMax
    buf.lsum = 0u;
    buf.count = 0u;
    buf.lsumHi = 0u;
    return;
  }

  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(outputImage);
  if(pos.x >= size.x || pos.y >= size.y)
    return;

  vec2 uv = (vec2(pos) + 0.5) / vec2(size);
  vec3 rgb = texture(inputTex, uv).rgb;
  float luma = dot(rgb, vec3(0.299, 0.587, 0.114));
  uint q = uint(clamp(luma, 0.0, 1.0) * SCALE + 0.5);

  atomicMin(buf.lmin, q);
  atomicMax(buf.lmax, q);
  // 8-bit-scaled sum with 64-bit carry so the accumulator survives multi-megapixel frames.
  uint add = uint(clamp(luma, 0.0, 1.0) * SUM_SCALE + 0.5);
  uint prev = atomicAdd(buf.lsum, add);
  if(prev + add < prev)
    atomicAdd(buf.lsumHi, 1u);
  atomicAdd(buf.count, 1u);

  imageStore(outputImage, pos, vec4(vec3(luma), 1.0));
}
