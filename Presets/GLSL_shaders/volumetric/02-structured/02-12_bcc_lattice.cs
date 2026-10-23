/*{
  "DESCRIPTION": "Body-centered cubic lattice of spheres \u2014 two interpenetrating grids.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 1.0,
      "MAX": 24.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": 0.05,
      "MAX": 0.6,
      "LABEL": "Radius"
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

    vec3 q = pc * scale;
    vec3 a = fract(q) - 0.5;
    vec3 b = fract(q + 0.5) - 0.5;
    float d = min(length(a), length(b));
    float v = 1.0 - smoothstep(radius*0.9, radius, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
