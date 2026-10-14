/*{
  "DESCRIPTION": "Neovius TPMS: 3(cos(x)+cos(y)+cos(z)) + 4 cos(x)cos(y)cos(z). Denser than Schwarz-P, more complex.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "INPUTS": [
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
      "DEFAULT": 1.2,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Thickness"
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

    vec3 q = pc * scale;
    float g = 3.0*(cos(q.x)+cos(q.y)+cos(q.z)) + 4.0*cos(q.x)*cos(q.y)*cos(q.z);
    float shell = 1.0 - smoothstep(thickness*0.5, thickness, abs(g));
    imageStore(volume, pos, vec4(vec3(shell), 1.0));

}
