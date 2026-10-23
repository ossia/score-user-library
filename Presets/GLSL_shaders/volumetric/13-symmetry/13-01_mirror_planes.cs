/*{
  "DESCRIPTION": "Mirror through XY / YZ / ZX planes (toggle each). Produces mandala-like symmetry in 3D. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "SYMMETRY"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "mirrorX",
      "TYPE": "bool",
      "DEFAULT": true,
      "LABEL": "Mirror X"
    },
    {
      "NAME": "mirrorY",
      "TYPE": "bool",
      "DEFAULT": true,
      "LABEL": "Mirror Y"
    },
    {
      "NAME": "mirrorZ",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Mirror Z"
    },
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn"
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
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec3 q = pc;
    if(mirrorX) q.x = abs(q.x);
    if(mirrorY) q.y = abs(q.y);
    if(mirrorZ) q.z = abs(q.z);
    imageStore(volOut, pos, texture(volIn, q*0.5 + 0.5));

}
