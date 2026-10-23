/*{
  "DESCRIPTION": "3D outer-totalistic cellular automaton with Generations (refractory) states. Each frame a cell counts its live neighbours among the 26 of its Moore neighbourhood (outside the volume counts as dead). A dead cell is born when the count is in the rule's birth set; a live cell stays alive when it is in the survival set, otherwise it starts dying: with States = 2 it dies at once (classic Life-like rules), with more it spends States - 2 frames in refractory states, where it neither counts as live nor can be reborn, before it is dead again (the Generations rule family, as in Mirek Wojtowicz's MCell and Softology's Visions of Chaos). Rules are written S(survive)/B(birth)/states. Presets: Pyroclastic S4-7/B6-8/10 (the default: from a central cluster, a churning volcanic front that fills the volume and keeps boiling); Bays 5766 and Bays 4555, Carter Bays' 3D Life rules (Candidates for the Game of Life in Three Dimensions, Complex Systems 1, 1987; his notation E_l E_u F_l F_u lists the survival range first, so 5766 is S5-7/B6 and 4555 is S4-5/B5; from a random soup of about 0.2 they settle within a few dozen frames into sparse still lifes and oscillators); Clouds S13-26/B13-14,17-19 (Softology's Clouds 1: seed a soup of density about 0.5, it condenses into smooth blobs); Boiling S6/B5-7 (keeps any seed boiling indefinitely); Custom uses Birth min..max, Survive min..max and States. Seed shape: Central cluster (default) fills a cube of a quarter of the volume's width at Seed density; Soup fills the whole volume. Re-seed restarts. Output (data, not colour): R = live (0/1); G = with States = 2 a trail of recently dead cells fading by 0.95 per frame, with more states the refractory countdown (1 = live, falling to 0 as a dying cell nears death: the state is decoded from G each frame); B = live neighbour count / 26.",
  "CREDIT": "ossia 3D catalog; rules after C. Bays (1987), M. Wojtowicz (MCell) and Softology (Visions of Chaos)",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "RESOURCES": [
    {
      "NAME": "rule",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [
        0,
        1,
        2,
        3,
        4,
        5
      ],
      "LABELS": [
        "Pyroclastic S4-7/B6-8/10",
        "Bays 5766 (S5-7/B6)",
        "Bays 4555 (S4-5/B5)",
        "Clouds S13-26/B13-14,17-19",
        "Boiling S6/B5-7",
        "Custom"
      ],
      "LABEL": "Rule"
    },
    {
      "NAME": "birthMin",
      "TYPE": "long",
      "DEFAULT": 6,
      "MIN": 0,
      "MAX": 26,
      "LABEL": "Birth min (Custom)"
    },
    {
      "NAME": "birthMax",
      "TYPE": "long",
      "DEFAULT": 8,
      "MIN": 0,
      "MAX": 26,
      "LABEL": "Birth max (Custom)"
    },
    {
      "NAME": "surviveMin",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 0,
      "MAX": 26,
      "LABEL": "Survive min (Custom)"
    },
    {
      "NAME": "surviveMax",
      "TYPE": "long",
      "DEFAULT": 7,
      "MIN": 0,
      "MAX": 26,
      "LABEL": "Survive max (Custom)"
    },
    {
      "NAME": "states",
      "TYPE": "long",
      "DEFAULT": 10,
      "MIN": 2,
      "MAX": 32,
      "LABEL": "States (Custom; 2 = no refractory period)"
    },
    {
      "NAME": "seedShape",
      "TYPE": "long",
      "DEFAULT": 1,
      "VALUES": [
        0,
        1
      ],
      "LABELS": [
        "Soup (whole volume)",
        "Central cluster"
      ],
      "LABEL": "Seed shape"
    },
    {
      "NAME": "seedDensity",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.01,
      "MAX": 0.8,
      "LABEL": "Seed density"
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

uint rangeMask(int lo, int hi){
    lo = clamp(lo, 0, 26);
    hi = clamp(hi, 0, 26);
    if(hi < lo) return 0u;
    return ((2u << uint(hi)) - 1u) & ~((1u << uint(lo)) - 1u);
}

bool inSet(uint m, int n){ return ((m >> uint(n)) & 1u) != 0u; }

int loadBin(in ivec3 c, in ivec3 sz){
    if(any(lessThan(c, ivec3(0))) || any(greaterThanEqual(c, sz))) return 0;
    return imageLoad(state_prev, c).r > 0.5 ? 1 : 0;
}

void main()
{
    ivec3 pos  = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(state);
    if(any(greaterThanEqual(pos, size))) return;
    vec4  prev = imageLoad(state_prev, pos);

    // Seed on the first dispatch. score currently starts FRAMEINDEX at 1, not
    // at 0 as the ISF spec says (see showcase/volume/_engine); <= 1 works either way.
    if(FRAMEINDEX <= 1 || seed){
        float h = hash13(vec3(pos) + vec3(TIME*3.0));
        float alive = step(1.0 - seedDensity, h);
        if(seedShape == 1){
            ivec3 lo = size * 3 / 8;
            ivec3 hi = size * 5 / 8;
            if(any(lessThan(pos, lo)) || any(greaterThanEqual(pos, hi))) alive = 0.0;
        }
        imageStore(state, pos, vec4(alive, alive, 0.0, 1.0));
        return;
    }

    uint birth, survive;
    int nStates;
    if(rule == 0)      { birth = rangeMask(6, 8);  survive = rangeMask(4, 7);   nStates = 10; }
    else if(rule == 1) { birth = rangeMask(6, 6);  survive = rangeMask(5, 7);   nStates = 2; }
    else if(rule == 2) { birth = rangeMask(5, 5);  survive = rangeMask(4, 5);   nStates = 2; }
    else if(rule == 3) { birth = rangeMask(13, 14) | rangeMask(17, 19); survive = rangeMask(13, 26); nStates = 2; }
    else if(rule == 4) { birth = rangeMask(5, 7);  survive = rangeMask(6, 6);   nStates = 2; }
    else {
        birth   = rangeMask(int(birthMin), int(birthMax));
        survive = rangeMask(int(surviveMin), int(surviveMax));
        nStates = clamp(int(states), 2, 32);
    }

    int live = 0;
    for(int dz = -1; dz <= 1; dz++)
    for(int dy = -1; dy <= 1; dy++)
    for(int dx = -1; dx <= 1; dx++){
        if(dx == 0 && dy == 0 && dz == 0) continue;
        live += loadBin(pos + ivec3(dx, dy, dz), size);
    }

    bool alive = prev.r > 0.5;
    float stepG = 1.0 / float(nStates - 1);
    // Refractory stage j (1 .. nStates - 2) of a dying cell, decoded from G.
    int j = alive ? 0 : int(round((1.0 - prev.g) * float(nStates - 1)));
    bool dying = nStates > 2 && !alive && j >= 1 && j <= nStates - 2;

    float nextR, nextG;
    if(alive){
        if(inSet(survive, live)){ nextR = 1.0; nextG = 1.0; }
        else if(nStates > 2)    { nextR = 0.0; nextG = 1.0 - stepG; }
        else                    { nextR = 0.0; nextG = prev.g * 0.95; }
    } else if(dying){
        nextR = 0.0;
        nextG = (j + 1 <= nStates - 2) ? 1.0 - float(j + 1) * stepG : 0.0;
    } else if(inSet(birth, live)){
        nextR = 1.0; nextG = 1.0;
    } else {
        nextR = 0.0;
        nextG = nStates > 2 ? 0.0 : prev.g * 0.95;
    }

    imageStore(state, pos, vec4(nextR, nextG, float(live) / 26.0, 1.0));
}
