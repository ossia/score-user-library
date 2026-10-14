/*{
  "DESCRIPTION": "N metaballs whose centres follow a stratified (Halton-sequence) distribution \u2014 covers the volume uniformly without regular-grid alignment. Each ball has a stable per-ball colour and size. Good for 'a field of floating orbs' base content. Very VJ-friendly as the N slider adjusts in real time.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "INPUTS": [
    {
      "NAME": "count",
      "TYPE": "long",
      "DEFAULT": 12,
      "MIN": 4,
      "MAX": 64,
      "LABEL": "Ball count"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.25,
      "MIN": 0.05,
      "MAX": 0.6,
      "LABEL": "Ball radius"
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
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Orbit speed"
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

// Halton sequence element for prime base b, index i. Produces a
// well-distributed point in [0,1] without the clumping of random().
float halton(int i, int b){
    float f = 1.0;
    float r = 0.0;
    while(i > 0){
        f /= float(b);
        r += f * float(i - (i / b) * b);
        i /= b;
    }
    return r;
}
vec3 haltonPoint3(int i){
    return vec3(halton(i + 1, 2), halton(i + 1, 3), halton(i + 1, 5));
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    int N = int(count);
    float f = 0.0;
    vec3 colAcc = vec3(0.0);
    float r2 = radius * radius;
    for(int n = 0; n < 64; n++){
        if(n >= N) break;
        vec3 base = haltonPoint3(n) * 2.0 - 1.0;
        // Small per-ball orbit so the field is alive
        vec3 orbit = 0.1 * vec3(
            sin(TIME * speed + float(n) * 1.31),
            cos(TIME * speed * 0.8 + float(n) * 0.73),
            sin(TIME * speed * 1.1 + float(n) * 2.17));
        vec3 c = base + orbit;
        vec3 d = pc - c;
        float influence = r2 / max(dot(d, d), 1e-4);
        f += influence;
        // Per-ball colour from the Halton triple, cycled through a palette
        vec3 col = 0.5 + 0.5 * cos(6.2831 * (base.xyz + vec3(0.0, 0.33, 0.67)));
        colAcc += col * influence;
    }
    float v = smoothstep(threshold * 0.7, threshold * 1.3, f);
    vec3 col = (f > 1e-4) ? colAcc / f : vec3(0.0);
    imageStore(volume, pos, vec4(col * v, v));

}
