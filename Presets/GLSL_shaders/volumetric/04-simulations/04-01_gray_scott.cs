/*{
  "DESCRIPTION": "3D Gray-Scott reaction-diffusion. Two chemicals U,V interact. Classic (F,k) recipes: (0.055, 0.062) = coral, (0.029, 0.057) = mitosis, (0.025, 0.050) = labyrinth, (0.014, 0.054) = bubbles. V (channel G) is the one you want to visualise. Re-seed with the event button to explore parameter space. The step is shortened automatically so that Diffusion x Timestep stays within the explicit scheme's stability limit, so large Timestep values past that limit change nothing.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "INPUTS": [
    {
      "NAME": "feedRate",
      "TYPE": "float",
      "DEFAULT": 0.055,
      "MIN": 0.0,
      "MAX": 0.1,
      "LABEL": "Feed rate F"
    },
    {
      "NAME": "killRate",
      "TYPE": "float",
      "DEFAULT": 0.062,
      "MIN": 0.0,
      "MAX": 0.1,
      "LABEL": "Kill rate k"
    },
    {
      "NAME": "diffU",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.01,
      "MAX": 1.0,
      "LABEL": "Diffusion U"
    },
    {
      "NAME": "diffV",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.01,
      "MAX": 1.0,
      "LABEL": "Diffusion V"
    },
    {
      "NAME": "dt",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 2.0,
      "LABEL": "Timestep"
    },
    {
      "NAME": "seed",
      "TYPE": "event",
      "LABEL": "Re-seed"
    }
  ],
  "RESOURCES": [
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
        float u = 1.0, v = 0.0;
        float h = hash13(vec3(pos) + vec3(TIME*13.0));
        // Pearson-style seed: a solid region at (0.5, 0.25) with a little
        // noise to break the symmetry (seeding only a random half of it
        // averages V down and the reaction dies out).
        if(dot(pc, pc) < 0.1){ u = 0.5 + 0.1*(h - 0.5); v = 0.25 + 0.1*(h - 0.5); }
        vec4 next = vec4(u, v, 0.0, 1.0);
        imageStore(state, pos, next);
        return;
    }
    float u = prev.r, v = prev.g;
    float lu = lap6(pos, size, 0);
    float lv = lap6(pos, size, 1);
    float uvv = u * v * v;
    // Explicit (FTCS) diffusion on the 6-neighbour stencil is only stable for
    // D * dt <= 1/6 per step (von Neumann analysis); above it the highest
    // spatial frequency grows every step and the volume turns into a
    // checkerboard. The step is capped just below that bound.
    const float kMaxDiffStep = 0.15;
    // Shrink the whole step rather than one coefficient, so Du/Dv (which the
    // patterns depend on) is preserved.
    float h = min(dt, kMaxDiffStep / max(max(diffU, diffV), 1e-6));
    float du = diffU * lu - uvv + feedRate * (1.0 - u);
    float dv = diffV * lv + uvv - (feedRate + killRate) * v;
    vec4 next = vec4(clamp(u + h*du, 0.0, 1.0),
                     clamp(v + h*dv, 0.0, 1.0),
                     v, 1.0);

    imageStore(state, pos, next);
}
