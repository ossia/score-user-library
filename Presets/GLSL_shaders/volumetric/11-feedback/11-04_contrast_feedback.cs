/*{
  "DESCRIPTION": "Contrast-feedback: accentuate differences between prev and current. Produces nervy shimmer when fed back. The result is clamped to [0, 1] in the shader on purpose: the clamp is what keeps the loop from diverging (gain > 0 amplifies every frame's difference). The output is rgba16f like the other volume filters, so the clamp is explicit in the code, not left to the storage format.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "FEEDBACK-LIKE"
  ],
  "INPUTS": [
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
      "NAME": "gain",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Difference gain"
    }
  ],
  "RESOURCES": [
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
    vec4 pr = texture(prev, p);
    vec4 d = (cu - pr) * gain;
    imageStore(volOut, pos, clamp(cu + d, 0.0, 1.0));
}
