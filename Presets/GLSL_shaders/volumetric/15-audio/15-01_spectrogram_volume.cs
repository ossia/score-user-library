/*{
  "DESCRIPTION": "Direct spectrogram-as-volume. X axis = frequency bin, Z axis = time (newest at z=0), Y axis = magnitude. Each voxel lit when the audio history contains a matching (freq, time) bin at or above the voxel's Y height. Most literal possible music visualiser.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "AUDIO"
  ],
  "INPUTS": [
    {
      "NAME": "history",
      "TYPE": "audioHistogram",
      "MAX": 256,
      "LABEL": "Audio history"
    },
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 0.5,
      "MAX": 16.0,
      "LABEL": "Magnitude gain"
    },
    {
      "NAME": "smoothness",
      "TYPE": "float",
      "DEFAULT": 0.05,
      "MIN": 0.005,
      "MAX": 0.2,
      "LABEL": "Edge smoothness"
    },
    {
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        0.6,
        0.2,
        1.0
      ],
      "LABEL": "Tint"
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

    float binX   = p.x;
    float timeY  = p.z;       // Z axis in volume = Y (time) in history
    float height = p.y;       // Y axis in volume = vertical position
    float mag = texture(history, vec2(binX, timeY)).r * scale;
    float lit = smoothstep(height - smoothness, height + smoothness, mag);
    imageStore(volume, pos, vec4(tint.rgb * lit, lit));

}
