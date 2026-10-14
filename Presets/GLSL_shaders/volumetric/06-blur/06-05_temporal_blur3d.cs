/*{
  "DESCRIPTION": "Temporal blur: each frame's output is an exponential moving average of the current input and the previous output. Persistent 3D image holds the running average. Low mix = heavy smoothing across time; high mix = fast response.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "BLUR"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "mixAmt",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.01,
      "MAX": 1.0,
      "LABEL": "Current weight"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "read_write",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn",
      "PERSISTENT": true
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
    ivec3 sz = imageSize(volOut);
    if(any(greaterThanEqual(pos, sz))) return;
    vec3 p = (vec3(pos) + 0.5) / vec3(sz);
    vec4 cur = texture(volIn, p);
    vec4 prev = imageLoad(volOut_prev, pos);
    vec4 next = mix(prev, cur, mixAmt);
    imageStore(volOut, pos, next);
}
