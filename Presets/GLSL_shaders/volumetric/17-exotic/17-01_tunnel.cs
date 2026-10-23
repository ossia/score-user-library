/*{
  "DESCRIPTION": "Infinite tunnel: remap (x,y,r) \u2192 unfolded cylinder, then tile a procedural texture. Classic demo staple.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "EXOTIC"
  ],
  "RESOURCES": [
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Speed"
    },
    {
      "NAME": "freqA",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Azimuth freq"
    },
    {
      "NAME": "freqR",
      "TYPE": "float",
      "DEFAULT": 6.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Radial freq"
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

    float r = length(pc.xy) + 1e-5;
    float a = atan(pc.y, pc.x);
    float z = pc.z + TIME*speed;
    float stripes = 0.5 + 0.5*sin(a*freqA + z*freqR);
    vec3 col = palette(stripes*0.5 + 0.25,
                       vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
    float fade = smoothstep(1.2, 0.3, r);
    imageStore(volume, pos, vec4(col * fade, fade));

}
