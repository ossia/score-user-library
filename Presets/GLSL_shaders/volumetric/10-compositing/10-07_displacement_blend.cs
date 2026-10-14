/*{
  "DESCRIPTION": "Displacement-driven blend: use a third volume as a mask that picks between A and B (with threshold + smoothness). The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COMPOSITE"
  ],
  "INPUTS": [
    {
      "NAME": "A",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "A"
    },
    {
      "NAME": "B",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "B"
    },
    {
      "NAME": "maskVol",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Mask"
    },
    {
      "NAME": "threshold",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Threshold"
    },
    {
      "NAME": "softness",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 0.5,
      "LABEL": "Softness"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_A",
      "HEIGHT": "$HEIGHT_A",
      "DEPTH": "$DEPTH_A"
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
    float m = texture(maskVol, p).r;
    float t = smoothstep(threshold - softness, threshold + softness, m);
    imageStore(volOut, pos, mix(texture(A, p), texture(B, p), t));
}
