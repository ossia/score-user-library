/*{
  "DESCRIPTION": "Mandelbulb (White / Nylander, power-n spherical formula) as a density: each voxel stores its escape iteration divided by Iterations (1 = never escaped, i.e. inside the set), so the field is stepped in 1/Iterations levels. An iso just below 1 shows the bulb. Zoom is the half-width of the sampled region (larger = more of the fractal, smaller on screen). Power drift oscillates the power over time and morphs the fractal.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "FRACTAL"
  ],
  "INPUTS": [
    {
      "NAME": "power",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 2.0,
      "MAX": 16.0,
      "LABEL": "Power"
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1.3,
      "MIN": 0.5,
      "MAX": 4.0,
      "LABEL": "Extent (zoom out)"
    },
    {
      "NAME": "iters",
      "TYPE": "long",
      "DEFAULT": 8,
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
      "LABEL": "Power drift"
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

    float Power = power + animate*sin(TIME);
    vec3 z = pc * zoom;
    vec3 c = z;
    float r = 0.0;
    int It = int(iters);
    int esc = It;
    for(int i=0; i<It; i++){
        r = length(z);
        if(r > 2.0){ esc = i; break; }
        float theta = acos(z.z/r);
        float phi = atan(z.y, z.x);
        float zr = pow(r, Power);
        theta *= Power; phi *= Power;
        z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
        z += c;
    }
    float v = float(esc)/float(It);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
