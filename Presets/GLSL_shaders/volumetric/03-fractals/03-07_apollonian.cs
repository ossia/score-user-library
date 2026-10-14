/*{
  "DESCRIPTION": "Apollonian sphere packing: inversive iteration, infinite detail.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "FRACTAL"
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
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 1.3,
      "MIN": 1.05,
      "MAX": 2.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.3,
      "MAX": 4.0,
      "LABEL": "Extent (zoom out)"
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

    vec3 z = pc * zoom;
    float s = 1.0;
    int It = int(iters);
    for(int i=0;i<It;i++){
        z = -1.0 + 2.0*fract(0.5*z + 0.5);
        float r2 = dot(z, z);
        float k = scale / max(r2, 1e-3);
        z *= k; s *= k;
    }
    float d = 0.25 * abs(z.y) / s;
    float v = 1.0 - smoothstep(0.0, 0.02, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
