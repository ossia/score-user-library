/*{
  "DESCRIPTION": "Bounded repetition of a sphere (I. Quilez, opRepLim): copies every Period along each axis, up to Limit copies on each side of the centre (0 = no repetition along that axis, fractional values stretch the outermost copy). A lattice of balls.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SDF"
  ],
  "RESOURCES": [
    {
      "NAME": "period",
      "TYPE": "float",
      "DEFAULT": 0.4,
      "MIN": 0.05,
      "MAX": 1.5,
      "LABEL": "Period"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.02,
      "MAX": 0.35,
      "LABEL": "Sphere radius"
    },
    {
      "NAME": "limitX",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Copies each side (X)"
    },
    {
      "NAME": "limitY",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Copies each side (Y)"
    },
    {
      "NAME": "limitZ",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Copies each side (Z)"
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

    vec3 lim = vec3(limitX, limitY, limitZ);
    // Bounded repetition (Iñigo Quilez opRepLim)
    vec3 q = pc - period*clamp(round(pc/period), -lim, lim);
    float d = length(q) - radius;
    float v = 1.0 - smoothstep(0.0, 0.02, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
