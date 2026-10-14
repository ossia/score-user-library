/*{
  "DESCRIPTION": "Moir\u00e9: multiply two analytical sinusoidal patterns at slightly different frequencies/angles.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "INPUTS": [
    {
      "NAME": "baseFreq",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 64.0,
      "LABEL": "Base freq"
    },
    {
      "NAME": "ratio",
      "TYPE": "float",
      "DEFAULT": 1.05,
      "MIN": 0.9,
      "MAX": 1.3,
      "LABEL": "Freq ratio"
    },
    {
      "NAME": "angleDeg",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 0.0,
      "MAX": 90.0,
      "LABEL": "Rotation (deg)"
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

    float ang = radians(angleDeg);
    mat3 R = mat3(cos(ang),-sin(ang),0.0, sin(ang),cos(ang),0.0, 0.0,0.0,1.0);
    vec3 a = pc;
    vec3 b = R * pc;
    float pa = sin(a.x*baseFreq)*sin(a.y*baseFreq)*sin(a.z*baseFreq);
    float pb = sin(b.x*baseFreq*ratio)*sin(b.y*baseFreq*ratio)*sin(b.z*baseFreq*ratio);
    float v = 0.5 + 0.5*(pa*pb);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
