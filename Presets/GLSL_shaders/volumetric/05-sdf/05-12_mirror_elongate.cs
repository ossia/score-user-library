/*{
  "DESCRIPTION": "Infinite mirror/elongation: pick a primitive, mirror-fold along an axis, elongate along another. Produces infinite corridors of shapes \u2014 great as base content for architectural raymarches.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SDF"
  ],
  "RESOURCES": [
    {
      "NAME": "shape",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [
        0,
        1,
        2
      ],
      "LABELS": [
        "Sphere",
        "Box",
        "Torus"
      ],
      "LABEL": "Shape"
    },
    {
      "NAME": "r",
      "TYPE": "float",
      "DEFAULT": 0.15,
      "MIN": 0.02,
      "MAX": 0.5,
      "LABEL": "Size"
    },
    {
      "NAME": "elongate",
      "TYPE": "point3D",
      "DEFAULT": [
        0.4,
        0.0,
        0.0
      ],
      "MIN": [
        0,
        0,
        0
      ],
      "MAX": [
        1,
        1,
        1
      ],
      "LABEL": "Elongation"
    },
    {
      "NAME": "mirror",
      "TYPE": "point3D",
      "DEFAULT": [
        0.0,
        0.3,
        0.0
      ],
      "MIN": [
        0,
        0,
        0
      ],
      "MAX": [
        1,
        1,
        1
      ],
      "LABEL": "Mirror period"
    },
    {
      "NAME": "softness",
      "TYPE": "float",
      "DEFAULT": 0.06,
      "MIN": 0.001,
      "MAX": 0.2,
      "LABEL": "Edge softness"
    },
    {
      "NAME": "volume",
      "TYPE": "image",
      "ACCESS": "write_only",
      "WIDTH": "64",
      "HEIGHT": "64",
      "DEPTH": "64"
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
        "TARGET": "volume"
      }
    }
  ]
}*/

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    // Elongation (IQ): extend the SDF along an axis without distortion
    vec3 q = pc - clamp(pc, -elongate, elongate);
    // Then mirror-fold through mirror period
    // Mirror-repeat only along axes with a non-zero period: folding with a
    // near-zero period (as an earlier version did) collapses that coordinate
    // to 0 and stretches the shape to infinity along it.
    vec3 m = max(mirror, vec3(1e-4));
    vec3 folded = abs(mod(q + m, 2.0*m) - m);
    q = mix(q, folded, step(vec3(1e-3), mirror));
    float d = 1e9;
    if(shape == 0){
        d = length(q) - r;
    } else if(shape == 1){
        vec3 qa = abs(q) - vec3(r);
        d = length(max(qa, 0.0)) + min(max(qa.x, max(qa.y, qa.z)), 0.0);
    } else {
        vec2 t = vec2(length(q.xz) - r, q.y);
        d = length(t) - r*0.3;
    }
    float v = 1.0 - smoothstep(0.0, softness, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
