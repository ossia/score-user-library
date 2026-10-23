/*{
  "DESCRIPTION": "3D box blur: the plain average of the (2 Radius + 1)^3 voxels around each voxel (27 taps at Radius 1, 343 at Radius 3). For small radii only; use the separable Gaussian (06-02) for wider blurs. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "BLUR"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "radius",
      "TYPE": "long",
      "DEFAULT": 1,
      "MIN": 1,
      "MAX": 3,
      "LABEL": "Radius"
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

    vec4 acc = vec4(0.0);
    float w = 0.0;
    int R = int(radius);
    vec3 invSize = 1.0 / vec3(size);
    for(int k=-R;k<=R;k++)
    for(int j=-R;j<=R;j++)
    for(int i=-R;i<=R;i++){
        vec3 uvw = (vec3(pos) + 0.5 + vec3(i,j,k)) * invSize;
        acc += texture(volIn, uvw);
        w   += 1.0;
    }
    imageStore(volOut, pos, acc / w);

}
