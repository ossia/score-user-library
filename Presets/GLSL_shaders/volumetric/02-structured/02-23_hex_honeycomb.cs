/*{
  "DESCRIPTION": "Hexagonal prisms stacked in 3D. Beehive volume.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "INPUTS": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 6.0,
      "MIN": 1.0,
      "MAX": 24.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "wallThickness",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.01,
      "MAX": 0.4,
      "LABEL": "Wall"
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

    // Hexagonal tiling of the XY plane: the hex centres form two offset
    // rectangular lattices of pitch (1, sqrt3); the nearer of the two centres
    // gives the cell, and the hexagon distance to it gives the wall
    // (I. Quilez, "hexagonal tiling"; see also redblobgames.com/grids/hexagons).
    vec2 q = p.xy * scale;
    const vec2 s = vec2(1.0, 1.7320508);
    vec2 ca = (floor(q / s) + 0.5) * s;
    vec2 cb = (floor((q - 0.5 * s) / s) + 1.0) * s;
    vec2 da = q - ca, db = q - cb;
    vec2 d = (dot(da, da) < dot(db, db)) ? da : db;
    // Distance from the centre to the edge along the hexagon's apothem
    // directions (pointy-top hexagon, apothem 0.5).
    vec2 ad = abs(d);
    float hexd = max(dot(ad, vec2(0.5, 0.8660254)), ad.x);
    float zwall = abs(fract(p.z*scale) - 0.5);
    float wall = step(0.5 - wallThickness, hexd) + step(0.5 - wallThickness, zwall);
    imageStore(volume, pos, vec4(vec3(clamp(wall, 0.0, 1.0)), 1.0));

}
