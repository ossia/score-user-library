/*{
  "DESCRIPTION": "Three animated metaballs merged with a polynomial smooth-union of their signed distances (I. Quilez smin), then baked as a density with a soft edge (1 inside, 0 outside). Unlike 02-16, which thresholds a sum of 1/r^2 fields, the surface here is exactly the smooth union of three spheres, with Merge smoothness setting the fillet radius.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SDF"
  ],
  "RESOURCES": [
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.25,
      "MIN": 0.05,
      "MAX": 0.6,
      "LABEL": "Ball radius"
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Orbit speed"
    },
    {
      "NAME": "k",
      "TYPE": "float",
      "DEFAULT": 0.18,
      "MIN": 0.0,
      "MAX": 0.5,
      "LABEL": "Merge smoothness"
    },
    {
      "NAME": "softness",
      "TYPE": "float",
      "DEFAULT": 0.06,
      "MIN": 0.001,
      "MAX": 0.2,
      "LABEL": "Edge softness"
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

float smin(float a, float b, float kk){
    kk = max(kk, 1e-4);
    float h = clamp(0.5 + 0.5*(b-a)/kk, 0.0, 1.0);
    return mix(b, a, h) - kk*h*(1.0-h);
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float t = TIME * speed;
    vec3 c1 = 0.4 * vec3(sin(t*1.1),  cos(t*1.3), sin(t*0.9));
    vec3 c2 = 0.4 * vec3(cos(t*1.7+1.0), sin(t*0.8+2.0), cos(t*1.2+0.5));
    vec3 c3 = 0.4 * vec3(sin(t*0.6+3.0), sin(t*1.4+1.5), cos(t*1.0+2.5));
    float d1 = length(pc - c1) - radius;
    float d2 = length(pc - c2) - radius;
    float d3 = length(pc - c3) - radius;
    float d = smin(smin(d1, d2, k), d3, k);
    float v = 1.0 - smoothstep(0.0, softness, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
