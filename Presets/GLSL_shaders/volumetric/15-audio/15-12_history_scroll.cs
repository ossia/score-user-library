/*{
  "DESCRIPTION": "Spectrogram scrolled along Z: the volume shows the last N frames of audio stacked in depth. Each Z slice is a single frame's full spectrum distributed radially. 30+ seconds of music visible at once.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "AUDIO"
  ],
  "RESOURCES": [
    {
      "NAME": "history",
      "TYPE": "audioHistogram",
      "MAX": 256,
      "LABEL": "Audio history"
    },
    {
      "NAME": "gain",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 0.1,
      "MAX": 20.0,
      "LABEL": "Gain"
    },
    {
      "NAME": "spread",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.2,
      "MAX": 2.0,
      "LABEL": "Radial spread"
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

    float r = length(pc.xy) * spread;
    float t = p.z;    // history coordinate (0 = newest)
    float mag = texture(history, vec2(r, t)).r * gain;
    float lit = smoothstep(0.0, 0.2, mag);
    vec3 col = palette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
    imageStore(volume, pos, vec4(col * lit * mag, lit));

}
