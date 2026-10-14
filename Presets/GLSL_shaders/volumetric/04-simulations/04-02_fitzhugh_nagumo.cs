/*{
  "DESCRIPTION": "FitzHugh-Nagumo excitable media in 3D. Classic model of nerve impulses / cardiac tissue. Activator u spreads as a wave; inhibitor v recovers behind it, making the medium refractory. Produces travelling wave-fronts, spiral scrolls, target patterns \u2014 excellent for organic pulsing VJ content. Seed resets the medium to its resting state and starts a scroll wave by cross-field stimulation (an excited quarter next to a refractory quarter). Defaults are FitzHugh's excitable setting (a = 0.7, b = 0.8, eps = 0.08). Output: R = u, G = v, B = 0.5 + 0.5 u.",
  "CREDIT": "ossia 3D catalog. R. FitzHugh, Impulses and physiological states in theoretical models of nerve membrane, Biophys. J. 1(6), 1961; J. Nagumo, S. Arimoto, S. Yoshizawa, Proc. IRE 50, 1962.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "INPUTS": [
    {
      "NAME": "a",
      "TYPE": "float",
      "DEFAULT": 0.7,
      "MIN": 0.1,
      "MAX": 1.5,
      "LABEL": "a (excitability)"
    },
    {
      "NAME": "b",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.001,
      "MAX": 1.5,
      "LABEL": "b (recovery)"
    },
    {
      "NAME": "eps",
      "TYPE": "float",
      "DEFAULT": 0.08,
      "MIN": 0.001,
      "MAX": 0.2,
      "LABEL": "epsilon (timescale)"
    },
    {
      "NAME": "diffU",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 4.0,
      "LABEL": "Diffusion u"
    },
    {
      "NAME": "dt",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.01,
      "MAX": 0.5,
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
        // Background at the resting state (u*, v*) -- the stable fixed point
        // where u - u^3/3 - v = 0 and u + a - b v = 0, found by Newton's
        // method -- with a few excited patches (u = 2) on top. Seeding the
        // background at u = v = 0 instead makes the whole medium fire at once
        // and relax uniformly, so no waves travel.
        float ur = -1.2;
        for(int k = 0; k < 8; k++){
            float f  = ur - ur*ur*ur/3.0 - (ur + a) / b;
            float fp = 1.0 - ur*ur - 1.0 / b;
            ur -= f / fp;
        }
        float vr = (ur + a) / b;
        // Cross-field stimulation (the standard way to start a spiral): below
        // y = 0 the half x < 0 is excited and the half x > 0 is made
        // refractory, so the wavefront has a free end along the z axis and
        // curls into a scroll wave that keeps rotating instead of sweeping
        // across once and dying out.
        float u = ur, v = vr;
        if(pc.y < 0.0){
            if(pc.x < 0.0) u = 2.0;
            else           v = vr + 1.5;
        }
        imageStore(state, pos, vec4(u, v, 0.0, 1.0));
        return;
    }
    float u = prev.r, v = prev.g;
    float lu = lap6(pos, size, 0);
    // Explicit (FTCS) diffusion on the 6-neighbour stencil is only stable for
    // D * dt <= 1/6 per step (von Neumann analysis); above it the highest
    // spatial frequency grows every step and the volume turns into a
    // checkerboard. The step is capped just below that bound.
    const float kMaxDiffStep = 0.15;
    float h = min(dt, kMaxDiffStep / max(diffU, 1e-6));
    float du = u - u*u*u/3.0 - v + diffU * lu;
    float dv = eps * (u + a - b*v);
    vec4 next = vec4(u + h*du, v + h*dv, 0.5 + 0.5*u, 1.0);

    imageStore(state, pos, next);
}
