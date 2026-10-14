/*{
  "DESCRIPTION": "3D Truchet pipes: each voxel cell contains a randomly oriented quarter-pipe. Interconnected tube volume.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "EXOTIC"
  ],
  "INPUTS": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 1.0,
      "MAX": 16.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.02,
      "MAX": 0.45,
      "LABEL": "Pipe radius"
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

// --- Hashing & random ----------------------------------------------------
float hash11(float n){ return fract(sin(n)*43758.5453123); }
float hash13(vec3 p){
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x*p.y*p.z*(p.x+p.y+p.z));
}
vec3 hash33(vec3 p){
    p = vec3(dot(p,vec3(127.1,311.7, 74.7)),
             dot(p,vec3(269.5,183.3,246.1)),
             dot(p,vec3(113.5,271.9,124.6)));
    return fract(sin(p) * 43758.5453123);
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    vec3 q = pc * scale;
    vec3 cell = floor(q);
    vec3 lp = fract(q) - 0.5;
    float h = hash13(cell);
    int orient = int(h * 8.0);
    if((orient & 1) == 1) lp.x = -lp.x;
    if((orient & 2) == 2) lp.y = -lp.y;
    if((orient & 4) == 4) lp.z = -lp.z;
    // Two orthogonal arcs from opposite corners
    float d1 = length(vec2(length(lp.xy - 0.5) - 0.5, lp.z)) - radius;
    float d2 = length(vec2(length(lp.yz - 0.5) - 0.5, lp.x)) - radius;
    float d = min(d1, d2);
    float v = 1.0 - smoothstep(0.0, 0.05, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
