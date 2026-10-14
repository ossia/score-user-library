/*{
  "DESCRIPTION": "3D Worley (cellular) noise, distance to the n-th nearest feature point \u2014 F1, F2, F3, F4. F1 (the default) is classic Worley noise, the distance to the nearest feature point: pebble / cell patterns (this mode replaces the former 01-04_worley_f1, which is archived). Higher orders give layered foam-like structures. Small scale \u2192 many cells, big scale \u2192 few.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "NOISE"
  ],
  "INPUTS": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 6.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "whichN",
      "TYPE": "long",
      "DEFAULT": 1,
      "VALUES": [
        1,
        2,
        3,
        4
      ],
      "LABELS": [
        "F1",
        "F2",
        "F3",
        "F4"
      ],
      "LABEL": "n-th nearest"
    },
    {
      "NAME": "drift",
      "TYPE": "float",
      "DEFAULT": 0.15,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Drift"
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

// Keep the 4 smallest distances.
vec4 worley4(vec3 x){
    vec3 p = floor(x); vec3 f = fract(x);
    vec4 F = vec4(1e9);
    for(int k=-1;k<=1;k++)
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++){
        vec3 b = vec3(i,j,k);
        vec3 r = b + hash33(p+b) - f;
        float d = length(r);
        // insert into sorted F vector
        if(d < F.x){ F.yzw = F.xyz; F.x = d; }
        else if(d < F.y){ F.zw = F.yz; F.y = d; }
        else if(d < F.z){ F.w = F.z; F.z = d; }
        else if(d < F.w){ F.w = d; }
    }
    return F;
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    vec4 F = worley4(pc * scale + vec3(TIME*drift));
    float v;
    if(whichN == 1) v = F.x;
    else if(whichN == 2) v = F.y;
    else if(whichN == 3) v = F.z;
    else                 v = F.w;
    v = clamp(v, 0.0, 1.0);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
