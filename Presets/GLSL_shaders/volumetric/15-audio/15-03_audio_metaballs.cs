/*{
  "DESCRIPTION": "Three 3D metaballs whose radii are driven by bass / mid / high frequency bands. The blobs pulse and merge with the music. Very VJ-friendly gooey audio-reactivity.",
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
      "NAME": "baseRadius",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.05,
      "MAX": 0.6,
      "LABEL": "Base radius"
    },
    {
      "NAME": "reactivity",
      "TYPE": "float",
      "DEFAULT": 2.5,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Pulse gain"
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.0,
      "MAX": 3.0,
      "LABEL": "Orbit speed"
    },
    {
      "NAME": "threshold",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.2,
      "MAX": 3.0,
      "LABEL": "Iso threshold"
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

    float t = TIME * speed;
    vec3 c1 = 0.45 * vec3(sin(t*1.1), cos(t*0.7), sin(t*0.9));
    vec3 c2 = 0.45 * vec3(cos(t*1.7+1.0), sin(t*0.8+2.0), cos(t*1.2+0.5));
    vec3 c3 = 0.45 * vec3(sin(t*0.6+3.0), sin(t*1.4+1.5), cos(t*1.0+2.5));
    float rBass = baseRadius * (1.0 + audioBass(fft) * reactivity);
    float rMid  = baseRadius * (1.0 + audioMid(fft)  * reactivity);
    float rHigh = baseRadius * (1.0 + audioHigh(fft) * reactivity);
    float f1 = rBass*rBass / max(dot(pc-c1,pc-c1), 1e-4);
    float f2 = rMid*rMid   / max(dot(pc-c2,pc-c2), 1e-4);
    float f3 = rHigh*rHigh / max(dot(pc-c3,pc-c3), 1e-4);
    float f = f1 + f2 + f3;
    float v = smoothstep(threshold * 0.7, threshold * 1.3, f);
    // Colour by which ball is closest
    vec3 col = vec3(1.0, 0.25, 0.25) * f1
             + vec3(0.3, 1.0, 0.4)   * f2
             + vec3(0.3, 0.5, 1.0)   * f3;
    col /= max(f, 1e-3);
    imageStore(volume, pos, vec4(col * v, v));

}
