/*{
  "DESCRIPTION": "Iterated abs-fold and sphere-fold with a scale that oscillates in time differently at every iteration, so the structure keeps evolving. The field is 1 - |z|/20 after the last iteration: close to 1 where the orbit stays small (the fractal) and 0 where it escapes, which is almost everywhere, so use a low iso (about 0.05) to see the solid.",
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
      "DEFAULT": 8,
      "MIN": 4,
      "MAX": 12,
      "LABEL": "Iterations"
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 0.4,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Speed"
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

    vec3 z = pc;
    int It = int(iters);
    float t = TIME*speed;
    for(int i=0;i<It;i++){
        z = abs(z);
        float r2 = dot(z,z);
        float k = 1.8 + 0.3*sin(t + float(i)*0.5);
        if(r2 < 0.25) z *= 4.0*k;
        else if(r2 < 1.0) z /= r2;
        z = k*z - vec3(0.5 + 0.2*sin(t+float(i)));
    }
    float v = 1.0 - clamp(length(z)*0.05, 0.0, 1.0);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
