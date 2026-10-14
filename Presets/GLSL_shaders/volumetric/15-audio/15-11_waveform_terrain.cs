/*{
  "DESCRIPTION": "Volumetric oscilloscope: the raw audio waveform (channel 0, time along X) is drawn as a sheet at height y = sample x Amplitude, Surface thickness thick, bent slightly in depth by the sample value. Silence is a flat sheet through the middle of the volume. Colour is Tint, premultiplied by the sheet density (alpha).",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "AUDIO"
  ],
  "INPUTS": [
    {
      "NAME": "waveform",
      "TYPE": "audio",
      "MAX": 1024,
      "LABEL": "Audio waveform"
    },
    {
      "NAME": "amplitude",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.1,
      "MAX": 4.0,
      "LABEL": "Amplitude"
    },
    {
      "NAME": "thickness",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.01,
      "MAX": 0.4,
      "LABEL": "Surface thickness"
    },
    {
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        0.2,
        1.0,
        0.7,
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

    // The audio texture stores 0.5 + sample / 2; decode to a signed sample.
    float w = texture(waveform, vec2(p.x, 0.0)).r * 2.0 - 1.0;
    float surfaceY = w * amplitude;
    float dy = abs(pc.y - surfaceY);
    // Z axis modulates which time window: slice forward in z = slightly delayed
    float d = mix(dy, dy + 0.5 * abs(pc.z - w), 0.3);
    float v = 1.0 - smoothstep(0.0, thickness, d);
    imageStore(volume, pos, vec4(tint.rgb * v, v));

}
