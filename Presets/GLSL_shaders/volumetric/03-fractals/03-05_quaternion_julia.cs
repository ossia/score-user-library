/*{
  "DESCRIPTION": "Quaternion Julia set sliced to 3D. Smooth organic blobs. c controls the shape.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "FRACTAL"
  ],
  "INPUTS": [
    {
      "NAME": "c",
      "TYPE": "point3d",
      "DEFAULT": [
        -0.2,
        0.4,
        -0.1
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
      "LABEL": "c (xyz)"
    },
    {
      "NAME": "cw",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -1.0,
      "MAX": 1.0,
      "LABEL": "c.w"
    },
    {
      "NAME": "iters",
      "TYPE": "long",
      "DEFAULT": 12,
      "MIN": 4,
      "MAX": 20,
      "LABEL": "Iterations"
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1.3,
      "MIN": 0.5,
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

    vec4 z = vec4(pc * zoom, 0.0);
    vec4 C = vec4(c, cw);
    int It = int(iters);
    int esc = It;
    for(int i=0;i<It;i++){
        vec4 z2 = vec4(
            z.x*z.x - z.y*z.y - z.z*z.z - z.w*z.w,
            2.0*z.x*z.y,
            2.0*z.x*z.z,
            2.0*z.x*z.w);
        z = z2 + C;
        if(dot(z,z) > 16.0){ esc = i; break; }
    }
    float v = float(esc)/float(It);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
