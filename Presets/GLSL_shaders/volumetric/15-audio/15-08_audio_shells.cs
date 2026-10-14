/*{
  "DESCRIPTION": "Concentric spherical shells emitted from the centre, where shell spacing pulses with bass. New shells appear on every beat-like spike. Radar / pulse feel.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "AUDIO"
  ],
  "INPUTS": [
    {
      "NAME": "fft",
      "TYPE": "audioFFT",
      "MAX": 256,
      "LABEL": "Audio spectrum"
    },
    {
      "NAME": "baseRings",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Base rings"
    },
    {
      "NAME": "reactivity",
      "TYPE": "float",
      "DEFAULT": 12.0,
      "MIN": 0.0,
      "MAX": 32.0,
      "LABEL": "Ring modulation"
    },
    {
      "NAME": "pulseSpeed",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Outward speed"
    },
    {
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        0.1,
        0.9,
        0.4,
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

float audioBand(sampler2D fft, float lo, float hi){
    const int N = 8;
    float acc = 0.0;
    for(int i = 0; i < N; i++){
        float x = mix(lo, hi, (float(i) + 0.5) / float(N));
        acc += texture(fft, vec2(x, 0.0)).r;
    }
    return acc / float(N);
}
float audioBass(sampler2D fft)   { return audioBand(fft, 0.00, 0.10); }
float audioLowMid(sampler2D fft) { return audioBand(fft, 0.10, 0.25); }
float audioMid(sampler2D fft)    { return audioBand(fft, 0.25, 0.50); }
float audioHigh(sampler2D fft)   { return audioBand(fft, 0.50, 1.00); }
// Overall amplitude from spectrum (broadband)
float audioAmp(sampler2D fft)    { return audioBand(fft,  0.0, 1.0); }

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float bass = audioBass(fft);
    float rings = baseRings + bass * reactivity;
    float r = length(pc);
    float v = 0.5 + 0.5 * sin(r * rings * 6.2831853 - TIME * pulseSpeed);
    // Weight intensity by bass so silence = faint shells
    v *= 0.2 + bass * 1.8;
    imageStore(volume, pos, vec4(tint.rgb * v, v));

}
