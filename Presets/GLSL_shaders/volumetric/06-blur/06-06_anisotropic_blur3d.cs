/*{
  "DESCRIPTION": "Anisotropic blur: Gaussian weights with an independent sigma (in voxels) per axis over a fixed 7x7x7 window, so sigmas above about 2 are truncated. Set an axis to 0 to leave it unblurred: (3, 0, 0) smears along X only, (0, 0, 3) only along Z. Not separable, so it costs 343 taps per voxel. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
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
      "NAME": "sigma",
      "TYPE": "point3D",
      "DEFAULT": [
        1.0,
        1.0,
        1.0
      ],
      "MIN": [
        0,
        0,
        0
      ],
      "MAX": [
        4,
        4,
        4
      ],
      "LABEL": "Sigma XYZ"
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

    vec3 invSize = 1.0 / vec3(size);
    vec3 s2 = max(sigma*sigma, vec3(1e-4));
    vec4 acc = vec4(0.0);
    float totalW = 0.0;
    const int R = 3;
    for(int k=-R;k<=R;k++)
    for(int j=-R;j<=R;j++)
    for(int i=-R;i<=R;i++){
        vec3 off = vec3(i, j, k);
        float w = exp(-0.5 * (off.x*off.x/s2.x + off.y*off.y/s2.y + off.z*off.z/s2.z));
        vec3 uvw = (vec3(pos) + 0.5 + off) * invSize;
        acc += w * texture(volIn, uvw);
        totalW += w;
    }
    imageStore(volOut, pos, acc / totalW);

}
