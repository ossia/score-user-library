/*{
  "DESCRIPTION": "Kaleidoscopic IFS: reflect-fold-scale. Syntopia-style alien architecture.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "FRACTAL"
  ],
  "INPUTS": [
    {
      "NAME": "offset",
      "TYPE": "point3d",
      "DEFAULT": [
        0.85,
        0.4,
        0.15
      ],
      "MIN": [
        -2.0,
        -2.0,
        -2.0
      ],
      "MAX": [
        2.0,
        2.0,
        2.0
      ],
      "LABEL": "Offset"
    },
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 2.5,
      "MIN": 1.1,
      "MAX": 3.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "iters",
      "TYPE": "long",
      "DEFAULT": 10,
      "MIN": 4,
      "MAX": 16,
      "LABEL": "Iterations"
    },
    {
      "NAME": "animate",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Rotate"
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

    float ang = TIME * animate * 0.3;
    mat3 R = mat3(cos(ang),-sin(ang),0.0, sin(ang),cos(ang),0.0, 0.0,0.0,1.0);
    vec3 z = pc * 1.5;
    int It = int(iters);
    for(int i=0;i<It;i++){
        z = abs(z);
        if(z.x < z.y) z.xy = z.yx;
        if(z.x < z.z) z.xz = z.zx;
        if(z.y < z.z) z.yz = z.zy;
        z = R * z;
        z = z*scale - offset*(scale-1.0);
    }
    float d = length(z) * pow(scale, -float(It));
    float v = 1.0 - smoothstep(0.0, 0.02, d - 0.01);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
