/*{
  "DESCRIPTION": "Concentric spherical shells: sin(length(p)*k - t). Pulsing target / onion.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "INPUTS": [
    {
      "NAME": "rings",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Rings"
    },
    {
      "NAME": "pulseSpeed",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Pulse speed"
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

    float r = length(pc);
    float v = 0.5 + 0.5*sin(r*rings*6.2831853 - TIME*pulseSpeed);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
