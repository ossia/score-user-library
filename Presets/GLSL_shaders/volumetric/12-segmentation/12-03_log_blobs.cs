/*{
  "DESCRIPTION": "Laplacian blob detector (a discrete stand-in for the Laplacian of Gaussian): the red channel is averaged over a 19-point stencil (centre, 6 face and 12 edge neighbours at a spacing of Scale voxels) and the centre is compared with that average. A bright blob about Scale voxels across, on a darker surround, lights up (output = (centre - average) x Gain, clamped to [0,1], alpha 1); flat regions, straight edges seen head-on and dark blobs stay black. Match Scale to the blob size you want to pick out. The input is read at full precision (signed or HDR fields work); the response is clamped to [0, 1] and stored rgba16f like the other volume filters.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "SEGMENTATION"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.5,
      "MAX": 4.0,
      "LABEL": "Scale (voxels)"
    },
    {
      "NAME": "gain",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.5,
      "MAX": 16.0,
      "LABEL": "Gain"
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

    vec3 invSize = scale / vec3(size);
    float C  = texture(volIn, p).r;
    float sum6 = 0.0, sum18 = 0.0;
    // 6-neighbour (axis)
    sum6 += texture(volIn, p + vec3( invSize.x,0,0)).r;
    sum6 += texture(volIn, p + vec3(-invSize.x,0,0)).r;
    sum6 += texture(volIn, p + vec3(0, invSize.y,0)).r;
    sum6 += texture(volIn, p + vec3(0,-invSize.y,0)).r;
    sum6 += texture(volIn, p + vec3(0,0, invSize.z)).r;
    sum6 += texture(volIn, p + vec3(0,0,-invSize.z)).r;
    // 12 edge neighbours
    const vec3 e[12] = vec3[12](
        vec3( 1, 1,0),vec3( 1,-1,0),vec3(-1, 1,0),vec3(-1,-1,0),
        vec3( 1,0, 1),vec3( 1,0,-1),vec3(-1,0, 1),vec3(-1,0,-1),
        vec3(0, 1, 1),vec3(0, 1,-1),vec3(0,-1, 1),vec3(0,-1,-1));
    for(int i=0;i<12;i++) sum18 += texture(volIn, p + e[i]*invSize).r;
    float blur = (C + sum6/6.0 + sum18/12.0) / 3.0;
    // blur - C is proportional to the Laplacian, which is negative on a
    // bright blob: C - blur lights bright blobs up.
    float v = clamp((C - blur) * 6.0 * gain, 0.0, 1.0);
    imageStore(volOut, pos, vec4(vec3(v), 1.0));

}
