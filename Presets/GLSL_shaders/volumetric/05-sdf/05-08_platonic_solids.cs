/*{
  "DESCRIPTION": "SDFs of the five Platonic solids \u2014 tetrahedron, cube, octahedron, dodecahedron, icosahedron. Exact distance fields based on the plane-cutting formulation (IQ). Classic VJ geometry.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SDF"
  ],
  "INPUTS": [
    {
      "NAME": "solid",
      "TYPE": "long",
      "DEFAULT": 2,
      "VALUES": [
        0,
        1,
        2,
        3,
        4
      ],
      "LABELS": [
        "Tetrahedron",
        "Cube",
        "Octahedron",
        "Dodecahedron",
        "Icosahedron"
      ],
      "LABEL": "Solid"
    },
    {
      "NAME": "r",
      "TYPE": "float",
      "DEFAULT": 0.55,
      "MIN": 0.1,
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

// Plane-folding helpers — max of (|p·n| - size) over n's gives the SDF.
float sdTetrahedron(vec3 p, float r){
    return (max(abs(p.x+p.y)-p.z, abs(p.x-p.y)+p.z) - r) / sqrt(3.0);
}
float sdOctahedron(vec3 p, float r){
    p = abs(p);
    return (p.x + p.y + p.z - r) * 0.57735027;
}
// Dodecahedron & icosahedron use the golden ratio
float sdDodecahedron(vec3 p, float r){
    const float phi = 1.6180339887;
    const float a = 1.0/sqrt(1.0+phi*phi);
    const float b = phi*a;
    p = abs(p);
    float d = max(p.x*b + p.y*a, max(p.y*b + p.z*a, p.z*b + p.x*a));
    return d - r;
}
float sdIcosahedron(vec3 p, float r){
    const float q = 2.6180339887; // 1 + phi
    p = abs(p);
    // Face normals: (1,1,1)/sqrt3 and the cyclic (1, phi^2, 0)/|.|. Each
    // family needs its own normalisation, otherwise the (1,1,1) planes sit
    // too far out and never cut, and the solid is not an icosahedron.
    float d = max((p.x + p.y + p.z) * 0.57735027,
                  max(p.x + p.y*q, max(p.y + p.z*q, p.z + p.x*q)) / sqrt(1.0 + q*q));
    return d - r * 0.8507;
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float d;
    if(solid == 0)      d = sdTetrahedron(pc, r);
    else if(solid == 1){ vec3 q = abs(pc) - vec3(r*0.55); d = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0); }
    else if(solid == 2) d = sdOctahedron(pc, r);
    else if(solid == 3) d = sdDodecahedron(pc, r*0.7);
    else                d = sdIcosahedron(pc, r);
    float v = 1.0 - smoothstep(0.0, softness, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
