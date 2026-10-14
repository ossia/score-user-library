/*{
  "DESCRIPTION": "Fold-orbit fog: every voxel iterates z -> |z| * 0.7 + bias/2 a few times and accumulates exp(-4|z|) along its orbit, giving a smooth, soft density whose shape follows the fold and Bias. It is a gather-style orbit-trap density, not the attractor of an iterated function system (that needs chaos-game scattering); for sharp folded fractals use 03-06 KIFS or 03-04.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "EXOTIC"
  ],
  "INPUTS": [
    {
      "NAME": "iters",
      "TYPE": "long",
      "DEFAULT": 6,
      "MIN": 3,
      "MAX": 10,
      "LABEL": "Iterations"
    },
    {
      "NAME": "bias",
      "TYPE": "point3d",
      "DEFAULT": [
        0.2,
        -0.1,
        0.3
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
      "LABEL": "Bias"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volume",
      "TYPE": "image",
      "ACCESS": "write_only",
      "WIDTH": "64",
      "HEIGHT": "64",
      "DEPTH": "64"
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
        "TARGET": "volume"
      }
    }
  ]
}*/

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    vec3 z = pc;
    int It = int(iters);
    float acc = 0.0;
    for(int i=0;i<It;i++){
        z = abs(z) * 0.7 + bias * 0.5;
        float r = length(z);
        acc += exp(-r*4.0);
    }
    float v = clamp(acc / float(It) * 4.0, 0.0, 1.0);
    imageStore(volume, pos, vec4(vec3(v), v));

}
