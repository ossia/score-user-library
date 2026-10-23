/*{
  "DESCRIPTION": "Smooth min / smooth max \u2014 SDF-style blended combinator with a smoothing radius. Smooth min can go below 0 and smooth max above 1: the output is rgba16f, so those values and signed or HDR inputs are kept.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COMPOSITE"
  ],
  "RESOURCES": [
    {
      "NAME": "A",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "A"
    },
    {
      "NAME": "B",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "B"
    },
    {
      "NAME": "k",
      "TYPE": "float",
      "DEFAULT": 0.15,
      "MIN": 0.0,
      "MAX": 0.5,
      "LABEL": "Smooth amount"
    },
    {
      "NAME": "useMin",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Min (else max)"
    },
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_A",
      "HEIGHT": "$HEIGHT_A",
      "DEPTH": "$DEPTH_A"
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

vec4 smin4(vec4 a, vec4 b, float k){
    vec4 h = clamp(0.5 + 0.5*(b - a)/max(k, 1e-4), 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
vec4 smax4(vec4 a, vec4 b, float k){
    vec4 h = clamp(0.5 - 0.5*(b - a)/max(k, 1e-4), 0.0, 1.0);
    return mix(b, a, h) + k*h*(1.0-h);
}
void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p = (vec3(pos)+0.5)/vec3(size);
    vec4 a = texture(A, p);
    vec4 b = texture(B, p);
    imageStore(volOut, pos, useMin ? smin4(a, b, k) : smax4(a, b, k));
}
