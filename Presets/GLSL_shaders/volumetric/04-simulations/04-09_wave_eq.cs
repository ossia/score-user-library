/*{
  "DESCRIPTION": "3D linear wave equation. Explicit leapfrog: u_new = 2u - u_prev + c\u00b2 \u0394t\u00b2 \u2207\u00b2u. R holds current u, G holds previous u. A pulse is injected at a user position on each trigger. Stable c\u00b7dt/dx < 1/\u221a3. Produces expanding spherical wavefronts and reflections off the box walls.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "INPUTS": [
    {
      "NAME": "c",
      "TYPE": "float",
      "DEFAULT": 0.4,
      "MIN": 0.05,
      "MAX": 0.55,
      "LABEL": "Wave speed c"
    },
    {
      "NAME": "damping",
      "TYPE": "float",
      "DEFAULT": 0.999,
      "MIN": 0.95,
      "MAX": 1.0,
      "LABEL": "Damping"
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
      "LABEL": "Pulse position"
    },
    {
      "NAME": "sourceFreq",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.1,
      "MAX": 8.0,
      "LABEL": "Pulse freq (Hz)"
    },
    {
      "NAME": "sourceAmp",
      "TYPE": "float",
      "DEFAULT": 0.25,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Pulse amplitude"
    },
    {
      "NAME": "pulse",
      "TYPE": "event",
      "LABEL": "Impulse"
    },
    {
      "NAME": "clear",
      "TYPE": "event",
      "LABEL": "Clear"
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
    if(FRAMEINDEX <= 1 || clear){
        imageStore(state, pos, vec4(0.0));
        return;
    }
    float u = prev.r;
    float uOld = prev.g;
    float lu = lap6(pos, size, 0);
    float c2 = c * c;
    float uNew = 2.0 * u - uOld + c2 * lu;
    uNew *= damping;
    // Source: continuous sine at sourcePos, plus one-shot on event
    float r = length(pc - sourcePos);
    float w = exp(-r*r * 400.0);
    uNew += sourceAmp * w * sin(TIME * sourceFreq * 6.283185);
    if(pulse) uNew += sourceAmp * w * 4.0;
    vec4 next = vec4(uNew, u, abs(uNew), 1.0);

    imageStore(state, pos, next);
}
