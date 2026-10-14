/*{
  "DESCRIPTION": "Bake a chosen SDF primitive (sphere / box / torus / capsule / cone) as a density volume. Useful as a starter for CSG chains.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SDF"
  ],
  "INPUTS": [
    {
      "NAME": "shape",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [
        0,
        1,
        2,
        3,
        4
      ],
      "LABELS": [
        "Sphere",
        "Box",
        "Torus",
        "Capsule",
        "Cone"
      ],
      "LABEL": "Shape"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.6,
      "MIN": 0.05,
      "MAX": 0.95,
      "LABEL": "Size"
    },
    {
      "NAME": "softness",
      "TYPE": "float",
      "DEFAULT": 0.06,
      "MIN": 0.001,
      "MAX": 0.2,
      "LABEL": "Edge softness"
    }
  ],
  "RESOURCES": [
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
    if(shape == 0){        // sphere
        d = length(pc) - radius;
    } else if(shape == 1){ // box
        vec3 q = abs(pc) - vec3(radius);
        d = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
    } else if(shape == 2){ // torus
        vec2 q = vec2(length(pc.xz) - radius, pc.y);
        d = length(q) - radius*0.3;
    } else if(shape == 3){ // capsule along y
        vec3 q = pc;
        q.y -= clamp(q.y, -radius, radius);
        d = length(q) - radius*0.35;
    } else {               // cone
        vec2 q = vec2(length(pc.xz), pc.y);
        vec2 c = vec2(sin(radians(30.0)), cos(radians(30.0)));
        d = max(dot(c, q), -q.y - radius);
    }
    float v = 1.0 - smoothstep(0.0, softness, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
