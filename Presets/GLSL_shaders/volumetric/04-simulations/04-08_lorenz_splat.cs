/*{
  "DESCRIPTION": "Lorenz strange-attractor density volume. Every voxel carries its own Lorenz trajectory (sigma, rho, beta; explicit Euler, Steps steps of dt per frame), persisted in the state, and adds a Gaussian splat to itself whenever that trajectory passes near it. Because the Lorenz flow is ergodic on the attractor, each voxel's time-average converges to the attractor's invariant density at that voxel, so the butterfly emerges over a few hundred frames. Decay sets the averaging window. Output: R = density; G, B, A hold the voxel's trajectory point (state, not colour), so view it with Density from = Red.",
  "CREDIT": "ossia 3D catalog. E. N. Lorenz, Deterministic Nonperiodic Flow, J. Atmos. Sci. 20, 1963.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "INPUTS": [
    {
      "NAME": "sigma",
      "TYPE": "float",
      "DEFAULT": 10.0,
      "MIN": 1.0,
      "MAX": 20.0,
      "LABEL": "sigma"
    },
    {
      "NAME": "rho",
      "TYPE": "float",
      "DEFAULT": 28.0,
      "MIN": 1.0,
      "MAX": 60.0,
      "LABEL": "rho"
    },
    {
      "NAME": "beta",
      "TYPE": "float",
      "DEFAULT": 2.667,
      "MIN": 0.5,
      "MAX": 6.0,
      "LABEL": "beta"
    },
    {
      "NAME": "dt",
      "TYPE": "float",
      "DEFAULT": 0.005,
      "MIN": 0.001,
      "MAX": 0.02,
      "LABEL": "Integrator dt"
    },
    {
      "NAME": "steps",
      "TYPE": "long",
      "DEFAULT": 12,
      "MIN": 4,
      "MAX": 64,
      "LABEL": "Steps per frame"
    },
    {
      "NAME": "decay",
      "TYPE": "float",
      "DEFAULT": 0.98,
      "MIN": 0.9,
      "MAX": 1.0,
      "LABEL": "Decay"
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

void main()
{
    ivec3 pos  = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(state);
    if(any(greaterThanEqual(pos, size))) return;
    vec3  p    = (vec3(pos) + 0.5) / vec3(size);
    vec3  pc   = p * 2.0 - 1.0;
    vec4  prev = imageLoad(state_prev, pos);

    // State layout: R = accumulated density at this voxel, GBA = this voxel's
    // own Lorenz trajectory point, persisted from frame to frame. (Restarting
    // the trajectory from the same seed every frame, as an earlier version
    // did, never lets it reach the attractor.) A persisted point is never
    // exactly (0,0,0) -- the origin is an unstable fixed point -- so all-zero
    // GBA means "not seeded yet", which also covers undefined first-frame data.
    vec3 q = prev.gba;
    // Seed on the first dispatch. score currently starts FRAMEINDEX at 1, not
    // at 0 as the ISF spec says (see showcase/volume/_engine); <= 1 works either way.
    bool fresh = seed || FRAMEINDEX <= 1 || dot(q, q) < 1e-6 || any(isnan(q)) || any(isinf(q));
    if(fresh){
        q = (vec3(hash13(vec3(pos) + 0.0),
                  hash13(vec3(pos) + 7.3),
                  hash13(vec3(pos) + 17.1)) * 2.0 - 1.0) * 20.0;
        q.z += 25.0;
    }

    // Explicit Euler steps of dx/dt = sigma (y - x), dy/dt = x (rho - z) - y,
    // dz/dt = x y - beta z. By ergodicity, the time this voxel's trajectory
    // spends near the voxel converges to the attractor's invariant density
    // there, so the butterfly builds up in R over a few hundred frames.
    int N = int(steps);
    float hit = 0.0;
    for(int i = 0; i < N; i++){
        vec3 dq = vec3(sigma * (q.y - q.x),
                       q.x * (rho - q.z) - q.y,
                       q.x * q.y - beta * q.z);
        q += dq * dt;
        // Map Lorenz space (x in [-25,25], y in [-30,30], z in [0,55]) to the cube.
        vec3 mapped = vec3(q.x / 25.0, q.y / 30.0, (q.z - 25.0) / 27.5);
        vec3 d = mapped - pc;
        hit += exp(-dot(d, d) * 100.0);
    }
    float density = (fresh ? 0.0 : prev.r) * decay + hit;
    imageStore(state, pos, vec4(density, q));
}
