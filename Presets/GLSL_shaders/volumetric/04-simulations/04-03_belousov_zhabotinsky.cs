/*{
  "DESCRIPTION": "3D Belousov-Zhabotinsky-style oscillator, after Alasdair Turner's simple cyclic three-species model (not the Oregonator): each concentration A, B, C diffuses, then grows by consuming the next one and is consumed by the previous one (a' = a + dt a (alpha c - gamma b), and cyclically). Produces 3D scroll waves that rotate around vortex cores, target patterns and expanding rings. Stored as RGB; view any channel or composite them.",
  "CREDIT": "ossia 3D catalog. A. Turner, A simple model of the Belousov-Zhabotinsky reaction from first principles, Bartlett School of Graduate Studies, UCL, 2009.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "RESOURCES": [
    {
      "NAME": "alpha",
      "TYPE": "float",
      "DEFAULT": 1.2,
      "MIN": 0.5,
      "MAX": 3.0,
      "LABEL": "alpha"
    },
    {
      "NAME": "beta",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.5,
      "MAX": 3.0,
      "LABEL": "beta"
    },
    {
      "NAME": "gamma",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.5,
      "MAX": 3.0,
      "LABEL": "gamma"
    },
    {
      "NAME": "diff",
      "TYPE": "float",
      "DEFAULT": 0.15,
      "MIN": 0.01,
      "MAX": 0.15,
      "LABEL": "Diffusion"
    },
    {
      "NAME": "dt",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.05,
      "MAX": 1.0,
      "LABEL": "Timestep"
    },
    {
      "NAME": "seed",
      "TYPE": "event",
      "LABEL": "Re-seed"
    },
    {
      "NAME": "state",
      "TYPE": "image",
      "ACCESS": "read_write",
      "FORMAT": "rgba16f",
      "WIDTH": "64",
      "HEIGHT": "64",
      "DEPTH": "64",
      "PERSISTENT": true
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
        "TARGET": "state"
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

// Clamp-to-edge 3D voxel load
vec4 loadC(in ivec3 c, in ivec3 sz) {
    return imageLoad(state_prev, clamp(c, ivec3(0), sz - 1));
}
// 6-neighbour Laplacian of the given channel index (0=r,1=g,2=b,3=a)
float lap6(in ivec3 p, in ivec3 sz, int ch) {
    float c = imageLoad(state_prev, p)[ch];
    float s = loadC(p + ivec3( 1,0,0), sz)[ch]
            + loadC(p + ivec3(-1,0,0), sz)[ch]
            + loadC(p + ivec3(0, 1,0), sz)[ch]
            + loadC(p + ivec3(0,-1,0), sz)[ch]
            + loadC(p + ivec3(0,0, 1), sz)[ch]
            + loadC(p + ivec3(0,0,-1), sz)[ch];
    return s - 6.0 * c;
}
// 3D gradient via central differences on channel `ch`
vec3 grad3(in ivec3 p, in ivec3 sz, int ch) {
    return 0.5 * vec3(
        loadC(p + ivec3( 1,0,0), sz)[ch] - loadC(p + ivec3(-1,0,0), sz)[ch],
        loadC(p + ivec3(0, 1,0), sz)[ch] - loadC(p + ivec3(0,-1,0), sz)[ch],
        loadC(p + ivec3(0,0, 1), sz)[ch] - loadC(p + ivec3(0,0,-1), sz)[ch]);
}

void main()
{
    ivec3 pos  = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(state);
    if(any(greaterThanEqual(pos, size))) return;
    vec3  p    = (vec3(pos) + 0.5) / vec3(size);
    vec3  pc   = p * 2.0 - 1.0;
    vec4  prev = imageLoad(state_prev, pos);

    // Seed on the first dispatch. score currently starts FRAMEINDEX at 1, not
    // at 0 as the ISF spec says (see showcase/volume/_engine); <= 1 works either way.
    if(FRAMEINDEX <= 1 || seed){
        float h1 = hash13(vec3(pos) + 0.0);
        float h2 = hash13(vec3(pos) + 7.3);
        float h3 = hash13(vec3(pos) + 17.7);
        imageStore(state, pos, vec4(h1, h2, h3, 1.0));
        return;
    }
    float a = prev.r, b = prev.g, c = prev.b;
    // Diffuse each concentration
    float la = lap6(pos, size, 0);
    float lb = lap6(pos, size, 1);
    float lc = lap6(pos, size, 2);
    // Explicit (FTCS) diffusion on the 6-neighbour stencil is only stable for
    // D * dt <= 1/6 per step (von Neumann analysis); above it the highest
    // spatial frequency grows every step and the volume turns into a
    // checkerboard. The step is capped just below that bound.
    const float kMaxDiffStep = 0.15;
    float Dd = min(diff, kMaxDiffStep);
    float ad = a + Dd * la;
    float bd = b + Dd * lb;
    float cd = c + Dd * lc;
    // Reaction (cyclic: A catalysed by C, B by A, C by B)
    float na = ad + dt * ad * (alpha * cd - gamma * bd);
    float nb = bd + dt * bd * (beta  * ad - alpha * cd);
    float nc = cd + dt * cd * (gamma * bd - beta  * ad);
    vec4 next = vec4(clamp(vec3(na, nb, nc), 0.0, 1.0), 1.0);

    imageStore(state, pos, next);
}
