/*{
  "DESCRIPTION": "Three moving 3D metaballs summed as density. Classic demoscene gooey blobs.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.35,
      "MIN": 0.05,
      "MAX": 0.8,
      "LABEL": "Radius"
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Speed"
    },
    {
      "NAME": "threshold",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 3.0,
      "LABEL": "Iso threshold"
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

    float t = TIME * speed;
    vec3 c1 = 0.5 * vec3(sin(t*1.1), cos(t*1.3), sin(t*0.9));
    vec3 c2 = 0.5 * vec3(cos(t*1.7+1.0), sin(t*0.8+2.0), cos(t*1.2+0.5));
    vec3 c3 = 0.5 * vec3(sin(t*0.6+3.0), sin(t*1.4+1.5), cos(t*1.0+2.5));
    float r2 = radius*radius;
    float f = r2/max(dot(pc-c1,pc-c1),1e-4)
            + r2/max(dot(pc-c2,pc-c2),1e-4)
            + r2/max(dot(pc-c3,pc-c3),1e-4);
    float v = smoothstep(threshold*0.7, threshold*1.3, f);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
