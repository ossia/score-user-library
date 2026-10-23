/*{
  "DESCRIPTION": "Spatial echo: output = current + k\u00b7prev(sampled with offset). Produces ghost copies. The feedback runs through the graph (a Delayed cable into 'prev'); 04-12_spatial_echo is the internal-feedback counterpart (PERSISTENT ping-pong, plus a rotation), with no cable loop to build. The sum is clamped to [0, 1] in the shader on purpose: the clamp is what keeps the loop bounded (without it the echo grows to current / (1 - gain)). The output is rgba16f like the other volume filters, so the clamp is explicit in the code, not left to the storage format.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "FEEDBACK-LIKE"
  ],
  "RESOURCES": [
    {
      "NAME": "prev",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Previous frame (3D)"
    },
    {
      "NAME": "current",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Current frame (3D)"
    },
    {
      "NAME": "offset",
      "TYPE": "point3d",
      "DEFAULT": [
        0.01,
        0.0,
        0.01
      ],
      "MIN": [
        -0.2,
        -0.2,
        -0.2
      ],
      "MAX": [
        0.2,
        0.2,
        0.2
      ],
      "LABEL": "Offset"
    },
    {
      "NAME": "gain",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.0,
      "MAX": 1.2,
      "LABEL": "Echo gain"
    },
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_current",
      "HEIGHT": "$HEIGHT_current",
      "DEPTH": "$DEPTH_current"
    }
  ],
  "PASSES": [
    {
      "LOCAL_SIZE": [
        4,
        4,
        4
      ],
      "EXECUTION_MODEL": {
        "TYPE": "3D_IMAGE",
        "TARGET": "volOut"
      }
    }
  ]
}*/

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p = (vec3(pos)+0.5)/vec3(size);
    vec4 cu = texture(current, p);
    vec4 pr = texture(prev, p - offset) * gain;
    imageStore(volOut, pos, clamp(cu + pr, 0.0, 1.0));
}
