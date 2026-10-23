/*{
  "DESCRIPTION": "3D Perlin gradient noise (Perlin 2002, Improving Noise: 12 cube-edge gradients, quintic fade) written into a volume. Classic smooth organic look; foundation for clouds / terrain / turbulence. Scale stretches the frequency.",
  "CREDIT": "ossia 3D catalog. K. Perlin, Improving Noise, SIGGRAPH 2002.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "NOISE"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 0.5,
      "MAX": 32.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "timeScroll",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.0,
      "MAX": 2.0,
      "LABEL": "Time scroll"
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

// Perlin gradient noise (Perlin 2002, "Improving Noise"): a pseudo-random
// gradient per lattice corner, chosen among the 12 cube-edge directions, dotted
// with the offset to that corner, blended with the quintic fade
// 6t^5 - 15t^4 + 10t^3. Zero at every lattice point, unlike value noise
// (01-03), which interpolates random values and shows the lattice.
vec3 grad12(vec3 corner){
    float h = floor(hash13(corner) * 12.0);
    // The 12 edge midpoints of a cube: (+-1,+-1,0), (+-1,0,+-1), (0,+-1,+-1).
    float s1 = (mod(h, 2.0) < 1.0) ? 1.0 : -1.0;
    float s2 = (mod(floor(h * 0.5), 2.0) < 1.0) ? 1.0 : -1.0;
    if(h < 4.0) return vec3(s1, s2, 0.0);
    if(h < 8.0) return vec3(s1, 0.0, s2);
    return vec3(0.0, s1, s2);
}
float perlin(vec3 P){
    vec3 Pi = floor(P);
    vec3 Pf = fract(P);
    vec3 w  = Pf*Pf*Pf*(Pf*(Pf*6.0-15.0)+10.0); // quintic fade
    float n000 = dot(grad12(Pi+vec3(0,0,0)), Pf-vec3(0,0,0));
    float n100 = dot(grad12(Pi+vec3(1,0,0)), Pf-vec3(1,0,0));
    float n010 = dot(grad12(Pi+vec3(0,1,0)), Pf-vec3(0,1,0));
    float n110 = dot(grad12(Pi+vec3(1,1,0)), Pf-vec3(1,1,0));
    float n001 = dot(grad12(Pi+vec3(0,0,1)), Pf-vec3(0,0,1));
    float n101 = dot(grad12(Pi+vec3(1,0,1)), Pf-vec3(1,0,1));
    float n011 = dot(grad12(Pi+vec3(0,1,1)), Pf-vec3(0,1,1));
    float n111 = dot(grad12(Pi+vec3(1,1,1)), Pf-vec3(1,1,1));
    float nx00 = mix(n000, n100, w.x);
    float nx10 = mix(n010, n110, w.x);
    float nx01 = mix(n001, n101, w.x);
    float nx11 = mix(n011, n111, w.x);
    float nxy0 = mix(nx00, nx10, w.y);
    float nxy1 = mix(nx01, nx11, w.y);
    return mix(nxy0, nxy1, w.z);   // roughly [-1, 1]
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    float n = perlin(pc * scale + vec3(TIME*timeScroll));
    n = n * 0.5 + 0.5;
    imageStore(volume, pos, vec4(vec3(n), 1.0));

}
