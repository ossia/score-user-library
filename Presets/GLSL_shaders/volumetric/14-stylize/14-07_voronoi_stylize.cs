/*{
  "DESCRIPTION": "Voronoi stylization: each voxel adopts the color of its nearest feature point in a random 3D grid. Flattens the volume into faceted cells \u2014 low-poly / paper-craft look. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "STYLIZE"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "cellScale",
      "TYPE": "float",
      "DEFAULT": 6.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Cell scale"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn"
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
        "TARGET": "volOut"
      }
    }
  ]
}*/

vec3 hash33(vec3 p){
    p = vec3(dot(p, vec3(127.1,311.7, 74.7)),
             dot(p, vec3(269.5,183.3,246.1)),
             dot(p, vec3(113.5,271.9,124.6)));
    return fract(sin(p)*43758.5453123);
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec3 q = p * cellScale;
    vec3 P = floor(q);
    vec3 F = fract(q);
    float best = 1e9;
    vec3 bestPt = vec3(0.0);
    for(int k=-1;k<=1;k++)
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++){
        vec3 b = vec3(i,j,k);
        vec3 c = hash33(P + b);
        vec3 r = b + c - F;
        float d = dot(r,r);
        if(d < best){ best = d; bestPt = (P + b + c) / cellScale; }
    }
    vec4 c = texture(volIn, bestPt);
    imageStore(volOut, pos, c);

}
