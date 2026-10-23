/*{
  "DESCRIPTION": "Stochastic crystal growth from a central seed (an Eden-type accretion model, not random-walk diffusion-limited aggregation): each empty voxel touching the crystal solidifies with a probability proportional to its number of solid neighbours (26-neighbourhood), Branching and Density, and lower away from the centre. Gives coral / frost-like structures; growth is slow at the defaults, so raise Branching for a quick result. Solid voxels age in G.",
  "CREDIT": "ossia 3D catalog. For true DLA see T. A. Witten, L. M. Sander, Phys. Rev. Lett. 47, 1981; the Eden model: M. Eden, 4th Berkeley Symposium, 1961.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "RESOURCES": [
    {
      "NAME": "branching",
      "TYPE": "float",
      "DEFAULT": 0.02,
      "MIN": 0.001,
      "MAX": 0.2,
      "LABEL": "Branching rate"
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": 0.05,
      "MAX": 1.0,
      "LABEL": "Bias toward filling"
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

int solid(in ivec3 c, in ivec3 sz){
    c = clamp(c, ivec3(0), sz - 1);
    return imageLoad(state_prev, c).r > 0.5 ? 1 : 0;
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
        // Single seed at centre
        float s = (dot(pc, pc) < 0.005) ? 1.0 : 0.0;
        imageStore(state, pos, vec4(s, 0.0, 0.0, 1.0));
        return;
    }
    if(prev.r > 0.5){
        // Already solid — freeze, with age accumulating in G
        vec4 next = vec4(1.0, min(prev.g + 0.005, 1.0), 0.0, 1.0);
        imageStore(state, pos, next);
        return;
    }
    int n = 0;
    for(int dz = -1; dz <= 1; dz++)
    for(int dy = -1; dy <= 1; dy++)
    for(int dx = -1; dx <= 1; dx++){
        if(dx == 0 && dy == 0 && dz == 0) continue;
        n += solid(pos + ivec3(dx, dy, dz), size);
    }
    if(n == 0){
        imageStore(state, pos, vec4(0.0, 0.0, 0.0, 1.0));
        return;
    }
    // Probability scales with neighbour count and a falloff with distance from centre
    float r = length(pc);
    float prob = branching * float(n) * mix(1.0, 0.3, r) * density;
    float h = hash13(vec3(pos) + vec3(float(FRAMEINDEX) * 0.731));
    float next_state = (h < prob) ? 1.0 : 0.0;
    vec4 next = vec4(next_state, 0.0, float(n) / 26.0, 1.0);

    imageStore(state, pos, next);
}
