/*{
  "DESCRIPTION": "Rave strobe: sharp-time flash that fills the whole volume with a pulsing color. Use sparingly with a low duty cycle.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "EXOTIC"
  ],
  "INPUTS": [
    {
      "NAME": "bpm",
      "TYPE": "float",
      "DEFAULT": 128.0,
      "MIN": 30.0,
      "MAX": 300.0,
      "LABEL": "BPM"
    },
    {
      "NAME": "duty",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.01,
      "MAX": 0.9,
      "LABEL": "Duty"
    },
    {
      "NAME": "color",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        1.0,
        1.0,
        1.0
      ],
      "LABEL": "Color"
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

    float beat = fract(TIME * bpm / 60.0);
    float on = step(beat, duty);
    imageStore(volume, pos, vec4(color.rgb * on, on));

}
