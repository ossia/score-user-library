/*{
  "DESCRIPTION": "I-WP minimal surface: interpenetrating foam-like cells.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 1.0,
      "MAX": 16.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "thickness",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Thickness"
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

    vec3 q = pc * scale;
    float g = 2.0*(cos(q.x)*cos(q.y)+cos(q.y)*cos(q.z)+cos(q.z)*cos(q.x))
            - (cos(2.0*q.x)+cos(2.0*q.y)+cos(2.0*q.z));
    float shell = 1.0 - smoothstep(thickness*0.5, thickness, abs(g));
    imageStore(volume, pos, vec4(vec3(shell), 1.0));

}
