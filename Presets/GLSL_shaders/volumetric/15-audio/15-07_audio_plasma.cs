/*{
  "DESCRIPTION": "3D plasma with per-band frequency modulation. Bass warps the large wavelengths, treble modulates detail. Cosine palette colourises by amplitude; alpha is the amplitude and the colour is stored premultiplied by it.",
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
      "DEFAULT": 0.6,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Speed"
    },
    {
      "NAME": "reactivity",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Audio gain"
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

    float bass = audioBass(fft) * reactivity;
    float mid  = audioMid(fft)  * reactivity;
    float high = audioHigh(fft) * reactivity;
    float t = TIME * speed;
    float s = sin(pc.x * freq * (1.0 + bass) + t)
            + sin(pc.y * freq * (1.0 + mid) * 1.1 - t * 0.7)
            + sin(pc.z * freq * (1.0 + high) * 1.2 + t * 1.3)
            + sin((pc.x + pc.y) * freq * 0.7 + t)
            + sin((pc.y + pc.z) * freq * 0.8 - t * 1.1)
            + sin((pc.z + pc.x) * freq * 0.9 + t * 0.9);
    float v = s / 6.0 * 0.5 + 0.5;
    vec3 col = palette(v, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
    imageStore(volume, pos, vec4(col * v, v));

}
