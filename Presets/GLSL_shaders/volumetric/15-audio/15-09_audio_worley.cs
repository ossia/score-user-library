/*{
  "DESCRIPTION": "Worley noise where the cell sites drift with mid-range audio and the F2-F1 edge thickness pulses with bass. Produces cellular structure that wobbles and flexes with music.",
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
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 16.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "driftGain",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Cell drift"
    },
    {
      "NAME": "edgeGain",
      "TYPE": "float",
      "DEFAULT": 0.4,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Edge pulse"
    },
    {
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        0.9,
        0.3,
        0.6,
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

// --- Hashing & random ----------------------------------------------------
float hash11(float n){ return fract(sin(n)*43758.5453123); }
float hash13(vec3 p){
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x*p.y*p.z*(p.x+p.y+p.z));
}
vec3 hash33(vec3 p){
    p = vec3(dot(p,vec3(127.1,311.7, 74.7)),
             dot(p,vec3(269.5,183.3,246.1)),
             dot(p,vec3(113.5,271.9,124.6)));
    return fract(sin(p) * 43758.5453123);
}

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

float worleyEdge(vec3 q, float drift, float tOffset){
    vec3 P = floor(q);
    vec3 F = fract(q);
    float F1 = 1e9, F2 = 1e9;
    for(int k=-1;k<=1;k++)
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++){
        vec3 b = vec3(i,j,k);
        vec3 r = b + (hash33(P+b) + drift*sin(tOffset + hash13(P+b)*6.28)*0.5) - F;
        float d = dot(r,r);
        if(d < F1){ F2=F1; F1=d; } else if(d < F2){ F2=d; }
    }
    return sqrt(F2) - sqrt(F1);
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float mid  = audioMid(fft);
    float bass = audioBass(fft);
    float edge = worleyEdge(pc * scale, driftGain * mid, TIME);
    float v = 1.0 - smoothstep(0.0, 0.1 + bass * edgeGain, edge);
    imageStore(volume, pos, vec4(tint.rgb * v, v));

}
