/*{
  "DESCRIPTION": "3D Chladni: sum of 3D standing wave modes sin(n\u03c0x)sin(m\u03c0y)sin(k\u03c0z). Animates n,m,k to morph nodal surfaces.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "n",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 1.0,
      "MAX": 12.0,
      "LABEL": "n"
    },
    {
      "NAME": "m",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 12.0,
      "LABEL": "m"
    },
    {
      "NAME": "k",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 1.0,
      "MAX": 12.0,
      "LABEL": "k"
    },
    {
      "NAME": "animate",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Drift"
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

    float N = n + TIME*animate*0.5;
    float M = m + TIME*animate*0.7;
    float K = k + TIME*animate*0.3;
    const float kPi = 3.14159265;
    float c = sin(p.x*kPi*N) * sin(p.y*kPi*M) * sin(p.z*kPi*K)
            + sin(p.x*kPi*M) * sin(p.y*kPi*K) * sin(p.z*kPi*N);
    float v = 1.0 - abs(c);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
