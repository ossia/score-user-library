/*{
  "DESCRIPTION": "Hexagonal close-packed (HCP) sphere stacking: triangular layers stacked ABAB, the densest lattice-type packing of equal spheres (74%). Sphere diameter is one lattice unit, so Radius 0.5 makes neighbours touch; Scale sets how many spheres span the volume.",
  "CREDIT": "ossia 3D catalog. J. H. Conway, N. J. A. Sloane, Sphere Packings, Lattices and Groups, Springer, ch. 1.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 1.0,
      "MAX": 24.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "radius",
      "TYPE": "float",
      "DEFAULT": 0.48,
      "MIN": 0.1,
      "MAX": 0.6,
      "LABEL": "Radius"
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

    // Hexagonal close packing of spheres of diameter 1: triangular layers
    // (basis a1 = (1,0), a2 = (1/2, sqrt3/2)) stacked ABAB at spacing
    // sqrt(2/3), each B layer shifted onto the triangle centroids
    // (1/2, sqrt3/6). Conway & Sloane, Sphere Packings, Lattices and Groups, ch. 1.
    vec3 q = pc * scale;
    const float h = 0.81649658;          // sqrt(2/3)
    const float s3 = 0.8660254;          // sqrt(3)/2
    float dmin = 1e9;
    float k0 = floor(q.z / h + 0.5);
    for(int dk = -1; dk <= 1; dk++){
        float k = k0 + float(dk);
        vec2 o = (mod(k, 2.0) < 0.5) ? vec2(0.0) : vec2(0.5, 0.28867513);
        vec2 xy = q.xy - o;
        // Lattice coordinates in the (a1, a2) basis, then the 4 surrounding sites.
        float j = xy.y / s3;
        float i = xy.x - 0.5 * j;
        vec2 ij = floor(vec2(i, j));
        for(int u = 0; u <= 1; u++)
        for(int w = 0; w <= 1; w++){
            vec2 c = ij + vec2(u, w);
            vec2 site = vec2(c.x + 0.5 * c.y, c.y * s3) + o;
            dmin = min(dmin, length(vec3(q.xy - site, q.z - k * h)));
        }
    }
    float v = 1.0 - smoothstep(radius*0.9, radius, dmin);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
