/*{
  "DESCRIPTION": "Persistent trails: blend in an external 'current' 3D input over the previous frame, with per-frame decay. Internal-feedback version of 11-01_trail_decay (PERSISTENT ping-pong, no cable loop needed); use 11-01 when other nodes must act on the trail inside the loop. Drop this between any generator and a viewer for instant motion trails.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "RESOURCES": [
    {
      "NAME": "current",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Current frame (3D)"
    },
    {
      "NAME": "decay",
      "TYPE": "float",
      "DEFAULT": 0.95,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Decay"
    },
    {
      "NAME": "addGain",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Add gain"
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
    vec4 cur = texture(current, p);
    vec4 next = max(prev * decay, cur * addGain);

    imageStore(state, pos, next);
}
