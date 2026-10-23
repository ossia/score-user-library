/*{
  "DESCRIPTION": "Rounded SDF primitives: round-box, round-cylinder, round-cone. The `rounding` parameter adds an offset to the base shape \u2014 infinitely smooth corners, classic IQ-style aesthetic.",
  "CREDIT": "ossia 3D catalog. Distance functions after I. Quilez, iquilezles.org/articles/distfunctions.",
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
        "Round box",
        "Round cylinder",
        "Round cone"
      ],
      "LABEL": "Shape"
    },
    {
      "NAME": "r",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.1,
      "MAX": 0.9,
      "LABEL": "Main size"
    },
    {
      "NAME": "rounding",
      "TYPE": "float",
      "DEFAULT": 0.12,
      "MIN": 0.0,
      "MAX": 0.4,
      "LABEL": "Corner radius"
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

    float d = 1e9;
    if(shape == 0){        // round box
        vec3 q = abs(pc) - vec3(r - rounding);
        d = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - rounding;
    } else if(shape == 1){ // round cylinder
        vec2 d2 = vec2(length(pc.xz) - (r - rounding), abs(pc.y) - (r - rounding));
        d = min(max(d2.x, d2.y), 0.0) + length(max(d2, 0.0)) - rounding;
    } else {               // round cone: exact SDF (I. Quilez, sdRoundCone):
        // sphere r1 at the bottom, sphere r2 at the top, height h between
        // centres, joined by their common tangent cone. Centred on y = 0.
        float r1 = r * 0.5;
        float r2 = min(rounding, r1 * 0.9);
        float h  = r * 1.2;
        vec2 q = vec2(length(pc.xz), pc.y + 0.5 * h);
        float bb = (r1 - r2) / h;
        float aa = sqrt(1.0 - bb * bb);
        float k = dot(q, vec2(-bb, aa));
        if(k < 0.0)          d = length(q) - r1;
        else if(k > aa * h)  d = length(q - vec2(0.0, h)) - r2;
        else                 d = dot(q, vec2(aa, bb)) - r1;
    }
    float v = 1.0 - smoothstep(0.0, softness, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
