/*{
  "DESCRIPTION": "Per-voxel zoom warp: scale position by a factor before sampling. Combined with rotation in an outer chain gives spiral-zoom feedback. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
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
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1.1,
      "MIN": 0.5,
      "MAX": 2.0,
      "LABEL": "Zoom"
    },
    {
      "NAME": "rotY",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": -3.14,
      "MAX": 3.14,
      "LABEL": "Rot Y (rad)"
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

    float a = rotY;
    mat2 R = mat2(cos(a),-sin(a),sin(a),cos(a));
    vec3 q = pc / zoom;
    q.xz = R * q.xz;
    vec3 uvw = q*0.5 + 0.5;
    imageStore(volOut, pos, texture(volIn, uvw));

}
