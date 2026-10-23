/*{
  "DESCRIPTION": "Spatial 3D echo: each frame's output is the previous frame displaced by a velocity vector plus the current input at reduced gain. Produces ghost-trails that stream in a consistent direction \u2014 comet tails for any volume. Combine with rotation for spiral comet effects. Internal-feedback counterpart of 11-03_echo_offset (which takes the previous frame on a cable, so other nodes can act on it inside the loop).",
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
      "NAME": "direction",
      "TYPE": "point3D",
      "DEFAULT": [
        0.0,
        0.0,
        0.05
      ],
      "MIN": [
        -0.5,
        -0.5,
        -0.5
      ],
      "MAX": [
        0.5,
        0.5,
        0.5
      ],
      "LABEL": "Drift direction"
    },
    {
      "NAME": "decay",
      "TYPE": "float",
      "DEFAULT": 0.94,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Decay"
    },
    {
      "NAME": "addGain",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Current gain"
    },
    {
      "NAME": "rotate",
      "TYPE": "float",
      "DEFAULT": 0.01,
      "MIN": -0.3,
      "MAX": 0.3,
      "LABEL": "Rotate per frame (rad)"
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
    // Back-trace p by (-direction) and rotate around Y
    float a = -rotate;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    vec3 q = pc - direction;
    q.xz = R * q.xz;
    vec3 backUV = q * 0.5 + 0.5;
    ivec3 backVoxel = clamp(ivec3(backUV * vec3(size)), ivec3(0), size - 1);
    vec4 historyContribution = imageLoad(state_prev, backVoxel) * decay;
    vec4 cur = texture(current, p) * addGain;
    vec4 next = max(historyContribution, cur);

    imageStore(state, pos, next);
}
