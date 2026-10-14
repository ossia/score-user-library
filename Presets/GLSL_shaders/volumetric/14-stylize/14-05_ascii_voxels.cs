/*{
  "DESCRIPTION": "Blocky random-fill stylization: the volume is cut into Cell count^3 cubes; each cube's luminance is quantized to Density levels and the cube is filled with that probability (a hash per cube), so darker regions become sparser. Filled cubes take the cell's colour darkened to its band (premultiplied, alpha = 1 in filled cubes, 0 elsewhere). Despite the name, no characters are drawn. The output is rgba16f, so HDR colour is not clipped.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "STYLIZE"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "cellCount",
      "TYPE": "long",
      "DEFAULT": 32,
      "MIN": 8,
      "MAX": 64,
      "LABEL": "Cell count"
    },
    {
      "NAME": "levels",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 2,
      "MAX": 8,
      "LABEL": "Density levels"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn"
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
        "TARGET": "volOut"
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
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    float n = float(cellCount);
    vec3 cell = floor(p*n);
    vec3 centre = (cell + 0.5)/n;
    vec4 s = texture(volIn, centre);
    float L = dot(s.rgb, vec3(0.2126, 0.7152, 0.0722));
    float nl = float(levels);
    float Lq = floor(L*nl)/nl;
    // fill cell only in rough proportion to Lq using a hash threshold
    float h = hash13(cell);
    float v = step(h, Lq);
    imageStore(volOut, pos, vec4(s.rgb*Lq * v, v));

}
