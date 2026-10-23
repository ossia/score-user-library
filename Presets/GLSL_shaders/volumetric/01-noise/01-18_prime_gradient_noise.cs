/*{
  "DESCRIPTION": "Prime gradient noise: Perlin-like lattice noise using prime-based gradients to reduce axial periodicity. Looks similar to Perlin but with fewer visible grid artifacts at large scale.",
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
      "DEFAULT": 4.0,
      "MIN": 0.5,
      "MAX": 32.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "drift",
      "TYPE": "float",
      "DEFAULT": 0.15,
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

// Prime-gradient-inspired: build gradients from scrambled primes
vec3 pg_grad(vec3 i){
    vec3 h = hash33(i);
    // push hash through prime-offset cosines to reduce axis alignment
    return normalize(vec3(
        cos(h.x*6.2831 + h.y*2.0),
        cos(h.y*6.2831 + h.z*2.0),
        cos(h.z*6.2831 + h.x*2.0)
    ));
}
float pgn(vec3 P){
    vec3 i = floor(P), f = fract(P);
    vec3 w = f*f*f*(f*(f*6.0-15.0)+10.0);
    float v = 0.0;
    for(int dz=0; dz<2; dz++)
    for(int dy=0; dy<2; dy++)
    for(int dx=0; dx<2; dx++){
        vec3 o = vec3(dx,dy,dz);
        vec3 g = pg_grad(i+o);
        float n = dot(g, f - o);
        float wx = (dx==0) ? (1.0-w.x) : w.x;
        float wy = (dy==0) ? (1.0-w.y) : w.y;
        float wz = (dz==0) ? (1.0-w.z) : w.z;
        v += wx*wy*wz*n;
    }
    return v;
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float n = pgn(pc * scale + vec3(TIME*drift));
    n = n * 0.7 + 0.5;
    imageStore(volume, pos, vec4(vec3(clamp(n,0.0,1.0)), 1.0));

}
