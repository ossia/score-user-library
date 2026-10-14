/*{
  "DESCRIPTION": "Pure white noise: independent random value per voxel. Foundation for many filter chains (dither, reaction-diffusion seeds). Animates by reseeding with TIME.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "NOISE"
  ],
  "INPUTS": [
    {
      "NAME": "animate",
      "TYPE": "bool",
      "DEFAULT": true,
      "LABEL": "Animate"
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

// --- Hashing & random ----------------------------------------------------
float hash11(float n){ return fract(sin(n)*43758.5453123); }
float hash13(vec3 p){
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x*p.y*p.z*(p.x+p.y+p.z));
}
vec3 hash33(vec3 p){
    p = vec3(dot(p,vec3(127.1,311.7, 74.7)),
             dot(p,vec3(269.5,183.3,246.1)),
             dot(p,vec3(113.5,271.9,124.6)));
    return fract(sin(p) * 43758.5453123);
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float t = animate ? TIME : 0.0;
    float n = hash13(vec3(pos) + t*13.37);
    imageStore(volume, pos, vec4(vec3(n), 1.0));

}
