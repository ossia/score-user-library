/*{
  "DESCRIPTION": "Sierpinski tetrahedron fractal: iterated nearest-corner fold.",
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
      "MIN": 2,
      "MAX": 16,
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
      "NAME": "animate",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Rotate"
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

    vec3 a1 = vec3( 1,  1,  1);
    vec3 a2 = vec3(-1, -1,  1);
    vec3 a3 = vec3( 1, -1, -1);
    vec3 a4 = vec3(-1,  1, -1);
    float ang = TIME * animate * 0.5;
    mat3 R = mat3(cos(ang),0.0,-sin(ang), 0.0,1.0,0.0, sin(ang),0.0,cos(ang));
    vec3 z = R * pc * zoom;
    float scale = 2.0;
    int It = int(iters);
    for(int i=0;i<It;i++){
        vec3 c = a1; float d = dot(z-a1, z-a1);
        float d2 = dot(z-a2, z-a2); if(d2 < d){ d = d2; c = a2; }
        float d3 = dot(z-a3, z-a3); if(d3 < d){ d = d3; c = a3; }
        float d4 = dot(z-a4, z-a4); if(d4 < d){ d = d4; c = a4; }
        z = scale*z - c*(scale-1.0);
    }
    float distSphere = length(z) * pow(scale, -float(It)) - 0.02;
    float v = 1.0 - smoothstep(0.0, 0.02, distSphere);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
