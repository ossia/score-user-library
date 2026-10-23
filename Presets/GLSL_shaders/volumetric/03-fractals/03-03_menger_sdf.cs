/*{
  "DESCRIPTION": "Menger sponge as a density volume. Recursive Escher-like geometry.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "FRACTAL"
  ],
  "RESOURCES": [
    {
      "NAME": "iters",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 1,
      "MAX": 6,
      "LABEL": "Iterations"
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1.2,
      "MIN": 0.5,
      "MAX": 4.0,
      "LABEL": "Extent (zoom out)"
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

    vec3 q = pc * zoom;
    float d = max(max(abs(q.x), abs(q.y)), abs(q.z)) - 1.0;
    float s = 1.0;
    int It = int(iters);
    for(int i=0; i<It; i++){
        vec3 a = mod(q*s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0*abs(a));
        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        float c = (min(da, min(db, dc)) - 1.0) / s;
        d = max(d, c);
    }
    float v = 1.0 - smoothstep(0.0, 0.03, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
