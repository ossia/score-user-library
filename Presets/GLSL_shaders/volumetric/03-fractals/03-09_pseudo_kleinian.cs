/*{
  "DESCRIPTION": "Pseudo-Kleinian fold fractal (Knighty): very VJ-friendly alien-temple aesthetic.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "FRACTAL"
  ],
  "RESOURCES": [
    {
      "NAME": "cSize",
      "TYPE": "point3d",
      "DEFAULT": [
        1.0,
        1.1,
        1.3
      ],
      "MIN": [
        0.5,
        0.5,
        0.5
      ],
      "MAX": [
        2.0,
        2.0,
        2.0
      ],
      "LABEL": "CSize"
    },
    {
      "NAME": "iters",
      "TYPE": "long",
      "DEFAULT": 9,
      "MIN": 4,
      "MAX": 12,
      "LABEL": "Iterations"
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.3,
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

    vec3 z = pc * zoom;
    int It = int(iters);
    float DEfactor = 1.0;
    for(int i=0;i<It;i++){
        z = 2.0 * clamp(z, -cSize, cSize) - z;
        float r2 = dot(z, z);
        float k = max(1.2/r2, 1.0);
        z *= k; DEfactor *= k;
    }
    float rxy = length(z.xy) - 0.92;
    float d = 0.5 * max(rxy, abs(z.z)) / DEfactor;
    float v = 1.0 - smoothstep(0.0, 0.02, d);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
