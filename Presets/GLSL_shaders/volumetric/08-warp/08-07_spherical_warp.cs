/*{
  "DESCRIPTION": "Spherical / fisheye warp: remap cartesian \u2192 spherical before sampling \u2014 distorts the volume as if pulled through a spherical mirror. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
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
      "NAME": "amount",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Amount"
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

    float r = length(pc) + 1e-6;
    float r2 = pow(r, 1.0 + amount);     // non-linear radial remap
    vec3 q = pc * (r2/r);
    vec3 uvw = q*0.5 + 0.5;
    imageStore(volOut, pos, texture(volIn, uvw));

}
