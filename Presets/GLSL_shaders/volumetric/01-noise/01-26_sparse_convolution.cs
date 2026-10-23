/*{
  "DESCRIPTION": "Sparse-convolution noise: place N random impulses per 3D cell, convolve each with a radial Gaussian kernel. Band-limited and directionally isotropic. Higher impulse counts \u2192 smoother; lower \u2192 starry/sparkly. Character is cleaner than simplex fBm \u2014 useful for sci-fi / technical grain.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "NOISE"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 1.0,
      "MAX": 24.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "impulses",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 1,
      "MAX": 16,
      "LABEL": "Impulses/cell"
    },
    {
      "NAME": "kernelRadius",
      "TYPE": "float",
      "DEFAULT": 0.35,
      "MIN": 0.05,
      "MAX": 1.0,
      "LABEL": "Kernel radius"
    },
    {
      "NAME": "drift",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.0,
      "MAX": 3.0,
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

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    vec3 q = pc * scale + vec3(TIME * drift);
    vec3 P = floor(q);
    vec3 F = fract(q);
    int N = int(impulses);
    float sum = 0.0;
    for(int k=-1;k<=1;k++)
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++){
        vec3 c = P + vec3(i,j,k);
        // Per-cell: N impulses at pseudo-random positions, signed amplitudes
        for(int n = 0; n < N; n++){
            vec3 seed = c + vec3(float(n) * 1.17);
            vec3 offset = hash33(seed);                    // in [0,1]^3
            float signed_amp = hash13(seed + 3.14) * 2.0 - 1.0;
            vec3 impulseLocal = vec3(i,j,k) + offset - F;
            float r2 = dot(impulseLocal, impulseLocal) / (kernelRadius * kernelRadius);
            sum += signed_amp * exp(-r2);
        }
    }
    // Normalise roughly — sqrt(N) central-limit-ish
    float v = sum / sqrt(float(N) * 2.0) * 0.5 + 0.5;
    v = clamp(v, 0.0, 1.0);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
