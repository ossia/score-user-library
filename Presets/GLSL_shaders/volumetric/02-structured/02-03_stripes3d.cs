/*{
  "DESCRIPTION": "3D stripes along an arbitrary axis. Hard square or sine stripes.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "INPUTS": [
    {
      "NAME": "axis",
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
      "LABEL": "Axis"
    },
    {
      "NAME": "frequency",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 64.0,
      "LABEL": "Frequency"
    },
    {
      "NAME": "sineMode",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Sine (else square)"
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

    vec3 a = normalize(axis + 1e-6);
    float s = dot(pc, a);
    float t = s * frequency;
    float v = sineMode ? 0.5+0.5*sin(t*6.2831853) : step(0.0, sin(t*6.2831853));
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
