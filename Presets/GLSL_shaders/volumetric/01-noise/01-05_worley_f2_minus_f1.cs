/*{
  "DESCRIPTION": "3D Worley F2 \u2212 F1: outlines Voronoi cell *edges*. Neon-wireframe-cell aesthetic (very VJ).",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "NOISE"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 6.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "drift",
      "TYPE": "float",
      "DEFAULT": 0.15,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Drift"
    },
    {
      "NAME": "sharpness",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.5,
      "MAX": 8.0,
      "LABEL": "Edge sharpness"
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

// Worley 3D: returns vec2(F1, F2) — distances to nearest / 2nd-nearest feature points.
vec2 worley(vec3 x){
    vec3 p = floor(x);
    vec3 f = fract(x);
    float F1 = 1e9, F2 = 1e9;
    for(int k=-1;k<=1;k++)
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++){
        vec3 b = vec3(i,j,k);
        vec3 r = b + hash33(p+b) - f;
        float d = dot(r,r);
        if(d < F1){ F2 = F1; F1 = d; }
        else if(d < F2){ F2 = d; }
    }
    return sqrt(vec2(F1, F2));
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    vec2 w = worley(pc * scale + vec3(TIME*drift));
    float edge = 1.0 - clamp((w.y - w.x) * sharpness, 0.0, 1.0);
    imageStore(volume, pos, vec4(vec3(edge), 1.0));

}
