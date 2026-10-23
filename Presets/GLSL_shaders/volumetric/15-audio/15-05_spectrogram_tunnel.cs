/*{
  "DESCRIPTION": "Tunnel where the wall texture is the audio history spectrogram. Azimuth = frequency bin, depth = history (newest at viewer). Fly into your own music.",
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
      "NAME": "innerRadius",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 0.5,
      "LABEL": "Inner radius"
    },
    {
      "NAME": "brightness",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.1,
      "MAX": 16.0,
      "LABEL": "Brightness"
    },
    {
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        0.4,
        0.1,
        1.0
      ],
      "LABEL": "Tint"
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

    float r = length(pc.xy);
    float phi = atan(pc.y, pc.x) / 6.2831853 + 0.5; // [0,1]
    // History row 0 is the newest frame: put it at the +Z end, facing the viewer.
    float z = 1.0 - p.z;
    float mag = texture(history, vec2(phi, z)).r * brightness;
    // Energy pushed against the wall: high mag = visible at larger r
    float wall = smoothstep(innerRadius, 1.0, r);
    float lit = mag * wall * (1.0 - smoothstep(0.95, 1.1, r));
    imageStore(volume, pos, vec4(tint.rgb * lit, lit));

}
