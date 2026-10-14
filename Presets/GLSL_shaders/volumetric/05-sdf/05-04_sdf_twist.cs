/*{
  "DESCRIPTION": "Analytic twist deformation of a primitive: rotate xz by y\u00b7k. Produces spiraling solids. The twist is about Y, so the torus (a ring around Y) barely changes; use the box or capsule to see it.",
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
        2
      ],
      "LABELS": [
        "Box",
        "Torus",
        "Capsule"
      ],
      "LABEL": "Shape"
    },
    {
      "NAME": "twist",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.0,
      "MAX": 16.0,
      "LABEL": "Twist amt"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.1,
      "MAX": 0.8,
      "LABEL": "Size"
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

    // twist: rotate (x,z) by angle proportional to y
    float a = twist * pc.y;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    vec2 rxz = R * pc.xz;
    vec3 qp = vec3(rxz.x, pc.y, rxz.y);
    float d;
    if(shape == 0){
        vec3 qa = abs(qp) - vec3(radius);
        d = length(max(qa, 0.0)) + min(max(qa.x, max(qa.y, qa.z)), 0.0);
    } else if(shape == 1){
        vec2 qt = vec2(length(qp.xz) - radius, qp.y);
        d = length(qt) - radius*0.3;
    } else {
        vec3 c = qp; c.y -= clamp(c.y, -radius, radius);
        d = length(c) - radius*0.3;
    }
    float v = 1.0 - smoothstep(0.0, 0.02, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
