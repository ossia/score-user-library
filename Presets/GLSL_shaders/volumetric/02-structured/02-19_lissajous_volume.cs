/*{
  "DESCRIPTION": "3D Lissajous volume: density is distance to a parametric Lissajous space curve. Twisted ribbons.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "a",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 1.0,
      "MAX": 12.0,
      "LABEL": "a"
    },
    {
      "NAME": "b",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 1.0,
      "MAX": 12.0,
      "LABEL": "b"
    },
    {
      "NAME": "c",
      "TYPE": "float",
      "DEFAULT": 7.0,
      "MIN": 1.0,
      "MAX": 12.0,
      "LABEL": "c"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.08,
      "MIN": 0.01,
      "MAX": 0.3,
      "LABEL": "Tube radius"
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

    // Distance to the closed polyline through N samples of the curve (segment
    // distance, not point distance: sampled points alone leave the tube as a
    // string of separate beads once a*b*c is large).
    float dmin = 1e9;
    const int N = 256;
    vec3 prevC = vec3(0.0);
    for(int i=0;i<=N;i++){
        float t = 6.2831853 * float(i)/float(N) + TIME*0.1;
        vec3 C = 0.9*vec3(sin(a*t), sin(b*t+1.5), sin(c*t+0.7));
        if(i > 0){
            vec3 ab = C - prevC;
            float h = clamp(dot(pc - prevC, ab) / max(dot(ab, ab), 1e-8), 0.0, 1.0);
            dmin = min(dmin, length(pc - prevC - ab * h));
        }
        prevC = C;
    }
    float v = 1.0 - smoothstep(radius*0.8, radius*1.2, dmin);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
