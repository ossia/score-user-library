/*{
  "DESCRIPTION": "Trail / decay: output = max(prev * decay, current). Feed the output back into 'prev' for persistent trails (a Delayed cable in the graph). 04-11_trails is the same effect with the feedback kept inside the node (PERSISTENT ping-pong, no cable loop): use this one when something else must act on the trail inside the loop (11-02 advect, 11-06 disturb), 04-11 otherwise. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
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
      "NAME": "decay",
      "TYPE": "float",
      "DEFAULT": 0.96,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Decay"
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
    vec4 pr = texture(prev,    p) * decay;
    vec4 cu = texture(current, p);
    imageStore(volOut, pos, max(pr, cu));
}
