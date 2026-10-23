/*{
  "DESCRIPTION": "3D Chladni nodal surfaces where the (n, m, k) mode numbers are Base mode plus the bass, mid and treble band energies (band averages of the spectrum) times Reactivity. As the balance between bands shifts, the whole nodal geometry reconfigures.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "AUDIO"
  ],
  "RESOURCES": [
    {
      "NAME": "fft",
      "TYPE": "audioFFT",
      "MAX": 256,
      "LABEL": "Audio spectrum"
    },
    {
      "NAME": "baseMode",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 1.0,
      "MAX": 12.0,
      "LABEL": "Base mode"
    },
    {
      "NAME": "reactivity",
      "TYPE": "float",
      "DEFAULT": 6.0,
      "MIN": 0.0,
      "MAX": 16.0,
      "LABEL": "Mode modulation"
    },
    {
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        0.8,
        0.9,
        1.0,
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

    float n = baseMode + audioBass(fft)   * reactivity;
    float m = baseMode + audioMid(fft)    * reactivity;
    float k = baseMode + audioHigh(fft)   * reactivity;
    const float kPi = 3.14159265;
    float c = sin(p.x*kPi*n) * sin(p.y*kPi*m) * sin(p.z*kPi*k)
            + sin(p.x*kPi*m) * sin(p.y*kPi*k) * sin(p.z*kPi*n);
    float v = 1.0 - abs(c);
    imageStore(volume, pos, vec4(tint.rgb * v, v));

}
