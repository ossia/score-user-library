/*{
  "DESCRIPTION": "Axial shear: each slice along one axis is offset in another axis. Simple but powerful. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "WARP"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "shearX",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": -1.0,
      "MAX": 1.0,
      "LABEL": "Shear X by Y"
    },
    {
      "NAME": "shearZ",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -1.0,
      "MAX": 1.0,
      "LABEL": "Shear Z by Y"
    }
  ],
  "RESOURCES": [
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

    vec3 q = p - 0.5;
    q.x += shearX * q.y;
    q.z += shearZ * q.y;
    imageStore(volOut, pos, texture(volIn, q + 0.5));

}
