/*{
  "DESCRIPTION": "Semi-Lagrangian advection of a scalar field through an analytical rotating vortex, with small diffusion. A dye source at a user-chosen point continuously injects material. Produces swirling smoke-like structure that builds up and decays. Lightweight (no persistent velocity field).",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "INPUTS": [
    {
      "NAME": "axis",
      "TYPE": "point3D",
      "DEFAULT": [
        0.0,
        1.0,
        0.0
      ],
      "MIN": [
        -1,
        -1,
        -1
      ],
      "MAX": [
        1,
        1,
        1
      ],
      "LABEL": "Vortex axis"
    },
    {
      "NAME": "spinRate",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.0,
      "MAX": 6.0,
      "LABEL": "Spin rate"
    },
    {
      "NAME": "diffusion",
      "TYPE": "float",
      "DEFAULT": 0.05,
      "MIN": 0.0,
      "MAX": 0.5,
      "LABEL": "Diffusion"
    },
    {
      "NAME": "decay",
      "TYPE": "float",
      "DEFAULT": 0.995,
      "MIN": 0.9,
      "MAX": 1.0,
      "LABEL": "Decay"
    },
    {
      "NAME": "sourcePos",
      "TYPE": "point3D",
      "DEFAULT": [0.45, -0.3, 0.0],
      "MIN": [
        -1,
        -1,
        -1
      ],
      "MAX": [
        1,
        1,
        1
      ],
      "LABEL": "Source position"
    },
    {
      "NAME": "sourceSize",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.01,
      "MAX": 0.3,
      "LABEL": "Source size"
    },
    {
      "NAME": "dt",
      "TYPE": "float",
      "DEFAULT": 0.02,
      "MIN": 0.001,
      "MAX": 0.1,
      "LABEL": "Timestep"
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
    if(FRAMEINDEX <= 1){
        imageStore(state, pos, vec4(0.0));
        return;
    }
    // Analytical velocity: rotation around normalized axis at spinRate
    vec3 ax = normalize(axis + 1e-5);
    vec3 vel = cross(ax, pc) * spinRate;
    // Semi-Lagrangian back-trace in normalised [-1,1] coords
    vec3 pcBack = pc - vel * dt;
    // Convert back to voxel coords and sample (clamp-to-edge)
    vec3 backUV = pcBack * 0.5 + 0.5;
    ivec3 backVoxel = ivec3(backUV * vec3(size));
    vec4 advected = loadC(backVoxel, size);
    // Simple diffusion
    float lr = lap6(pos, size, 0);
    vec4 diffused = advected + vec4(diffusion * lr);
    // Dye source: Gaussian blob around sourcePos
    float r = length(pc - sourcePos);
    float inject = exp(-r*r / (sourceSize*sourceSize)) * 0.2;
    vec4 next = diffused * decay + vec4(inject, inject*0.7, inject*0.4, inject);
    next = clamp(next, 0.0, 2.0);

    imageStore(state, pos, next);
}
