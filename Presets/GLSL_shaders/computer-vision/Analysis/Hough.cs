/*{
  "DESCRIPTION": "Hough line transform: each bright (edge) pixel votes into a theta x rho accumulator SSBO via atomicAdd. Feed a thresholded edge map (e.g. EdgeDetect/Threshold output). Read back the accumulator with BufferToArray (UInt32/IntArray) = numTheta*numRho counts; peak-pick on the host to get lines. RESOLUTION IS FIXED at THETA_BINS(180) x RHO_BINS(256) = 46080 cells: the SSBO LAYOUT (uint[46080]) is a static, compile-time size, pass 0 clears it with exactly 180 workgroups x 256 invocations, and the host peak-picker assumes this 180x256 stride. The bin counts are therefore not runtime parameters; changing them requires editing the LAYOUT size, the pass-0 dispatch (WORKGROUPS) and the THETA_BINS/RHO_BINS constants together. 180x256 gives 1-degree theta resolution and 256 rho steps over the normalised diagonal, a good default for interactive line detection.",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": ["Computer Vision", "Analysis"],
  "RESOURCES": [
    { "NAME": "inputTex", "TYPE": "texture" },
    { "NAME": "threshold", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
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
        { "NAME": "accum", "TYPE": "uint[46080]" }
      ]
    }
  ],
  "PASSES": [
    { "LOCAL_SIZE": [256, 1, 1], "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [180, 1, 1] } },
    { "LOCAL_SIZE": [16, 16, 1], "EXECUTION_MODEL": { "TYPE": "2D_IMAGE" } }
  ]
}*/

// 180 theta bins x 256 rho bins = 46080. rho is normalised to [0,1] over [-sqrt2, +sqrt2]
// (image diagonal in normalised coords) and quantised to RHO_BINS.
// These are FIXED: they must stay in lockstep with the SSBO LAYOUT size (uint[46080]), the
// pass-0 clear dispatch (180 workgroups x 256 local invocations) and the host stride. Do not
// change one without the others.
const int THETA_BINS = 180;
const int RHO_BINS = 256;
const float PI = 3.14159265;

void main()
{
  if(PASSINDEX == 0)
  {
    // 180*256 cells cleared by 180 groups x 256 local invocations.
    uint t = gl_WorkGroupID.x;
    uint r = gl_LocalInvocationID.x;
    if(t < uint(THETA_BINS) && r < uint(RHO_BINS))
      buf.accum[t * uint(RHO_BINS) + r] = 0u;
    return;
  }

  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(outputImage);
  if(pos.x >= size.x || pos.y >= size.y)
    return;

  vec2 uv = (vec2(pos) + 0.5) / vec2(size);
  float e = dot(texture(inputTex, uv).rgb, vec3(0.299, 0.587, 0.114));

  imageStore(outputImage, pos, vec4(vec3(e), 1.0));

  if(e < threshold)
    return;

  // Normalised coordinates centred at the image middle.
  vec2 c = uv - vec2(0.5);

  // Vote across all theta. Diagonal of [-0.5,0.5]^2 is sqrt(0.5) ~ 0.7071.
  const float RHO_MAX = 0.70710678;
  for(int t = 0; t < THETA_BINS; ++t)
  {
    float theta = float(t) * PI / float(THETA_BINS);
    float rho = c.x * cos(theta) + c.y * sin(theta); // in [-RHO_MAX, RHO_MAX]
    int rbin = int((rho / RHO_MAX * 0.5 + 0.5) * float(RHO_BINS - 1) + 0.5);
    rbin = clamp(rbin, 0, RHO_BINS - 1);
    atomicAdd(buf.accum[uint(t) * uint(RHO_BINS) + uint(rbin)], 1u);
  }
}
