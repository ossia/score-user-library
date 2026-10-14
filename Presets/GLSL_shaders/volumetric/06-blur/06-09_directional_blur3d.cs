/*{
  "DESCRIPTION": "Directional (motion) blur: averages 17 samples along the Direction vector, from -Length to +Length voxels around each voxel. Produces streaks and wisps. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
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
      "NAME": "dir",
      "TYPE": "point3d",
      "DEFAULT": [
        1.0,
        0.0,
        0.0
      ],
      "MIN": [
        -1.0,
        -1.0,
        -1.0
      ],
      "MAX": [
        1.0,
        1.0,
        1.0
      ],
      "LABEL": "Direction"
    },
    {
      "NAME": "travel",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 0.5,
      "MAX": 20.0,
      "LABEL": "Length (voxels each side)"
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
    vec3 d = normalize(dir + 1e-6);
    const int N = 8;
    vec4 acc = vec4(0.0);
    for(int i=-N;i<=N;i++){
        vec3 offset = d * (float(i)/float(N)) * travel;
        vec3 uvw = (vec3(pos) + 0.5 + offset) * invSize;
        acc += texture(volIn, uvw);
    }
    imageStore(volOut, pos, acc/float(2*N+1));

}
