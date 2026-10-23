/*{
  "DESCRIPTION": "3D heat equation: \u2202u/\u2202t = \u03b1 \u2207\u00b2u. Simplest possible persistent-3D sim. A hot source voxel continuously injects energy, it spreads outward. Useful as a reference test for the persistent plumbing and as a building block (feed the output into a warp filter etc).",
  "CREDIT": "ossia 3D catalog",
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
      "DEFAULT": 0.15,
      "MIN": 0.01,
      "MAX": 0.15,
      "LABEL": "Diffusion"
    },
    {
      "NAME": "sourcePos",
      "TYPE": "point3D",
      "DEFAULT": [
        0.0,
        0.0,
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
      "LABEL": "Source"
    },
    {
      "NAME": "sourceSize",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.01,
      "MAX": 0.4,
      "LABEL": "Source size"
    },
    {
      "NAME": "sourceTemp",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Source temp"
    },
    {
      "NAME": "ambient",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Ambient temp"
    },
    {
      "NAME": "coolRate",
      "TYPE": "float",
      "DEFAULT": 0.995,
      "MIN": 0.9,
      "MAX": 1.0,
      "LABEL": "Cooling"
    },
    {
      "NAME": "clear",
      "TYPE": "event",
      "LABEL": "Clear"
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
    if(FRAMEINDEX <= 1 || clear){
        imageStore(state, pos, vec4(ambient, ambient, ambient, 1.0));
        return;
    }
    float u = prev.r;
    float lu = lap6(pos, size, 0);
    // Explicit (FTCS) diffusion on the 6-neighbour stencil is only stable for
    // D * dt <= 1/6 per step (von Neumann analysis); above it the highest
    // spatial frequency grows every step and the volume turns into a
    // checkerboard. The step is capped just below that bound.
    const float kMaxDiffStep = 0.15;
    float uNew = u + min(alpha, kMaxDiffStep) * lu;
    // Cool toward ambient
    uNew = mix(ambient, uNew, coolRate);
    // Source
    float r = length(pc - sourcePos);
    float w = smoothstep(sourceSize, 0.0, r);
    uNew = mix(uNew, sourceTemp, w);
    vec4 next = vec4(uNew, uNew, uNew, 1.0);

    imageStore(state, pos, next);
}
