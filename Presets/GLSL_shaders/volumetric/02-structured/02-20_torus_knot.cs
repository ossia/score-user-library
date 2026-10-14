/*{
  "DESCRIPTION": "(p,q) torus knot as a tube density: the curve winds p times around the central (Z) axis and q times around the torus tube, i.e. q times through the hole. p and q with no common factor give a single knot (2,3 = trefoil); otherwise the curve closes early into a torus link. Major radius sets the ring size, Tube radius the thickness of the drawn tube.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "INPUTS": [
    {
      "NAME": "pWind",
      "TYPE": "long",
      "DEFAULT": 2,
      "MIN": 2,
      "MAX": 7,
      "LABEL": "p"
    },
    {
      "NAME": "qWind",
      "TYPE": "long",
      "DEFAULT": 3,
      "MIN": 2,
      "MAX": 7,
      "LABEL": "q"
    },
    {
      "NAME": "R",
      "TYPE": "float",
      "DEFAULT": 0.55,
      "MIN": 0.2,
      "MAX": 0.9,
      "LABEL": "Major radius"
    },
    {
      "NAME": "rad",
      "TYPE": "float",
      "DEFAULT": 0.08,
      "MIN": 0.02,
      "MAX": 0.3,
      "LABEL": "Tube radius"
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

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float dmin = 1e9;
    const int N = 256;
    float P = float(pWind), Q = float(qWind);
    // Distance to the closed polyline through N samples of the knot: segment
    // distance, so the tube stays continuous at high windings.
    vec3 prevC = vec3(0.0);
    for(int i=0; i<=N; i++){
        float t = 6.2831853 * float(i)/float(N);
        vec3 C = vec3((R + 0.3*cos(Q*t))*cos(P*t),
                     (R + 0.3*cos(Q*t))*sin(P*t),
                     0.3*sin(Q*t));
        if(i > 0){
            vec3 ab = C - prevC;
            float h = clamp(dot(pc - prevC, ab) / max(dot(ab, ab), 1e-8), 0.0, 1.0);
            dmin = min(dmin, length(pc - prevC - ab * h));
        }
        prevC = C;
    }
    float v = 1.0 - smoothstep(rad*0.8, rad*1.2, dmin);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
