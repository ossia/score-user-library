/*{
  "DESCRIPTION": "Sum of three rotated plane waves. Sparkles when ray-marched.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "k1",
      "TYPE": "point3d",
      "DEFAULT": [
        4.0,
        0.0,
        0.0
      ],
      "MIN": [
        -32.0,
        -32.0,
        -32.0
      ],
      "MAX": [
        32.0,
        32.0,
        32.0
      ],
      "LABEL": "k1"
    },
    {
      "NAME": "k2",
      "TYPE": "point3d",
      "DEFAULT": [
        0.0,
        4.0,
        2.0
      ],
      "MIN": [
        -32.0,
        -32.0,
        -32.0
      ],
      "MAX": [
        32.0,
        32.0,
        32.0
      ],
      "LABEL": "k2"
    },
    {
      "NAME": "k3",
      "TYPE": "point3d",
      "DEFAULT": [
        2.0,
        -2.0,
        4.0
      ],
      "MIN": [
        -32.0,
        -32.0,
        -32.0
      ],
      "MAX": [
        32.0,
        32.0,
        32.0
      ],
      "LABEL": "k3"
    },
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

    float v = (sin(dot(pc, k1)+TIME) + sin(dot(pc, k2)+TIME*1.3) + sin(dot(pc, k3)+TIME*0.7)) / 3.0;
    v = v * 0.5 + 0.5;
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
