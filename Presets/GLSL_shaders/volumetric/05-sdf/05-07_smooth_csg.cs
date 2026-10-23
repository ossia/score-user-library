/*{
  "DESCRIPTION": "Signed-distance CSG of two animated spheres: union, intersection or subtraction (the first minus the second), hard or smooth. k is the smoothing radius (Inigo Quilez's polynomial smooth min / max, https://iquilezles.org/articles/smin/): k = 0 is the hard operation (min / max), larger k blends the two surfaces into a soft organic joint. Replaces the former 05-02_sdf_csg (archived): its hard ops are k = 0, its smooth union is Union with k = its smooth amount.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SDF"
  ],
  "RESOURCES": [
    {
      "NAME": "op",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [
        0,
        1,
        2
      ],
      "LABELS": [
        "Union",
        "Intersection",
        "Subtraction"
      ],
      "LABEL": "Op"
    },
    {
      "NAME": "k",
      "TYPE": "float",
      "DEFAULT": 0.15,
      "MIN": 0.0,
      "MAX": 0.5,
      "LABEL": "Smoothness k (0 = hard)"
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

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    vec3 c1 = 0.25 * vec3(sin(TIME), cos(TIME*1.3), sin(TIME*0.7));
    vec3 c2 = 0.25 * vec3(cos(TIME*0.9+1.0), sin(TIME*1.1+2.0), cos(TIME*0.6+0.5));
    float d1 = length(pc - c1) - 0.45;
    float d2 = length(pc - c2) - 0.40;
    float kk = max(k, 1e-4);
    float d;
    if(k <= 0.0){
        if(op == 0)      d = min(d1, d2);
        else if(op == 1) d = max(d1, d2);
        else             d = max(d1, -d2);
    } else if(op == 0){        // smooth union (IQ polynomial)
        float h = clamp(0.5 + 0.5*(d2-d1)/kk, 0.0, 1.0);
        d = mix(d2, d1, h) - kk*h*(1.0-h);
    } else if(op == 1){ // smooth intersection
        float h = clamp(0.5 - 0.5*(d2-d1)/kk, 0.0, 1.0);
        d = mix(d2, d1, h) + kk*h*(1.0-h);
    } else {            // smooth subtraction (d1 minus d2)
        float h = clamp(0.5 - 0.5*(d2+d1)/kk, 0.0, 1.0);
        d = mix(d1, -d2, h) + kk*h*(1.0-h);
    }
    float v = 1.0 - smoothstep(0.0, softness, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
