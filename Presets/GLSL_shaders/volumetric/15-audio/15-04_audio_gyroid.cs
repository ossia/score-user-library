/*{
  "DESCRIPTION": "Gyroid TPMS with its shell thickness driven by audio amplitude. Bass pumps make the lattice fatten; silence makes it thin down to wires. The scale axis also shimmies with mid-band.",
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
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 6.0,
      "MIN": 1.0,
      "MAX": 24.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "baseThickness",
      "TYPE": "float",
      "DEFAULT": 0.05,
      "MIN": 0.01,
      "MAX": 0.3,
      "LABEL": "Base thickness"
    },
    {
      "NAME": "reactivity",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Audio gain"
    },
    {
      "NAME": "animate",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Drift"
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

    float bass = audioBass(fft);
    float mid  = audioMid(fft);
    float scaleMod = scale * (1.0 + 0.2 * mid);
    vec3 q = pc * scaleMod + vec3(TIME * animate);
    float g = sin(q.x)*cos(q.y) + sin(q.y)*cos(q.z) + sin(q.z)*cos(q.x);
    float thickness = baseThickness + bass * reactivity * 0.3;
    float shell = 1.0 - smoothstep(thickness*0.5, thickness, abs(g));
    imageStore(volume, pos, vec4(vec3(shell), shell));

}
