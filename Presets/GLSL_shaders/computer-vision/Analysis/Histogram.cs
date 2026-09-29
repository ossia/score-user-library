/*{
  "DESCRIPTION": "256-bin luminance histogram via GPU reduction into an SSBO, read back with BufferToArray (UInt32 / IntArray) as 256 counts. Drives brightness-distribution -> control mappings, auto-contrast, exposure metering. RESOLUTION IS FIXED at 256 bins: the SSBO LAYOUT (uint[256]) is a static, compile-time size and pass 0 clears exactly 256 bins with 256 invocations, so the bin count is not a runtime parameter. 256 matches 8-bit luma exactly (1 bin per code), which is the natural choice for rgba8 input; changing it would require editing the LAYOUT size, the pass-0 clear count and the bin-index quantiser together.",
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
        { "NAME": "bins", "TYPE": "uint[256]" }
      ]
    }
  ],
  "PASSES": [
    { "LOCAL_SIZE": [256, 1, 1], "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [1, 1, 1] } },
    { "LOCAL_SIZE": [16, 16, 1], "EXECUTION_MODEL": { "TYPE": "2D_IMAGE" } }
  ]
}*/

void main()
{
  if(PASSINDEX == 0)
  {
    // 256 invocations clear 256 bins (one each).
    uint i = gl_GlobalInvocationID.x;
    if(i < 256u)
      buf.bins[i] = 0u;
    return;
  }

  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(outputImage);
  if(pos.x >= size.x || pos.y >= size.y)
    return;

  vec2 uv = (vec2(pos) + 0.5) / vec2(size);
  vec3 rgb = texture(inputTex, uv).rgb;
  float luma = dot(rgb, vec3(0.299, 0.587, 0.114));

  // Fixed 256 bins (static SSBO layout) -> one bin per 8-bit luma code.
  uint bin = uint(clamp(luma, 0.0, 1.0) * 255.0 + 0.5);
  // Each bin counts +1 per pixel; a uint32 bin holds up to ~4.29e9, so it only overflows
  // if a single bin gets > 4.29e9 px (a >65k x 65k image of one luma) -- not a real concern.
  atomicAdd(buf.bins[bin], 1u);

  imageStore(outputImage, pos, vec4(vec3(luma), 1.0));
}
