/*{
  "DESCRIPTION": "3D plasma: sum of many sinusoidal terms of different directions and frequencies, remapped through a palette.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "EXOTIC"
  ],
  "INPUTS": [
    {
      "NAME": "freq",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 0.5,
      "MAX": 16.0,
      "LABEL": "Base freq"
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.0,
      "MAX": 4.0,
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

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d){
    return a + b * cos(6.28318530718 * (c*t + d));
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float t = TIME*speed;
    float s = sin(pc.x*freq + t) + sin(pc.y*freq*1.1 - t*0.7)
            + sin(pc.z*freq*1.2 + t*1.3)
            + sin((pc.x+pc.y)*freq*0.7 + t)
            + sin((pc.y+pc.z)*freq*0.8 - t*1.1)
            + sin((pc.z+pc.x)*freq*0.9 + t*0.9);
    float v = s/6.0 * 0.5 + 0.5;
    vec3 col = palette(v, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
    imageStore(volume, pos, vec4(col, 1.0));

}
