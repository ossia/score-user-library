/*{
  "DESCRIPTION": "Mandelbox: box-fold + sphere-fold iterations. Alien architecture.",
  "CREDIT": "ossia 3D catalog. Mandelbox by Tom Lowe (2010), box fold + sphere fold with fixed radius 1.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "FRACTAL"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": -2.5,
      "MIN": -4.0,
      "MAX": 4.0,
      "LABEL": "Scale (neg \u2192 classic)"
    },
    {
      "NAME": "minR",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.1,
      "MAX": 1.5,
      "LABEL": "MinRadius"
    },
    {
      "NAME": "iters",
      "TYPE": "long",
      "DEFAULT": 10,
      "MIN": 4,
      "MAX": 16,
      "LABEL": "Iterations"
    },
    {
      "NAME": "animate",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Scale drift"
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

    float S = scale + animate*sin(TIME*0.4);
    vec3 z = pc * 1.5;
    vec3 c = z;
    int It = int(iters);
    int esc = It;
    float mr2 = minR*minR;
    for(int i=0; i<It; i++){
        z = clamp(z, -1.0, 1.0) * 2.0 - z;
        float r2 = dot(z, z);
        // Sphere fold with fixed radius 1: scale by 1/minR^2 inside minR
        // (the old constant 4.0 was only right for minR = 0.5).
        if(r2 < mr2) z /= mr2;
        else if(r2 < 1.0) z /= r2;
        z = S*z + c;
        if(dot(z,z) > 64.0){ esc = i; break; }
    }
    float v = float(esc)/float(It);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
