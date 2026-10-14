/*{
  "DESCRIPTION": "Bit-plane glitch: per-voxel XOR of integer coordinates, shifted with time. Very 8-bit.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "EXOTIC"
  ],
  "INPUTS": [
    {
      "NAME": "shift",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 1,
      "MAX": 8,
      "LABEL": "Bit shift"
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Speed"
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

    uint x = uint(pos.x), y = uint(pos.y), z = uint(pos.z);
    uint t = uint(TIME * speed * 8.0);
    uint v = ((x ^ y) >> uint(shift)) ^ ((y ^ z) >> uint(shift)) ^ t;
    float g = float(v & 7u) / 7.0;
    float b = float((v >> 3u) & 7u) / 7.0;
    float r = float((v >> 6u) & 7u) / 7.0;
    imageStore(volume, pos, vec4(r, g, b, 1.0));

}
