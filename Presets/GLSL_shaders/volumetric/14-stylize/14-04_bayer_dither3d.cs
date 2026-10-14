/*{
  "DESCRIPTION": "Random-threshold dither: each colour channel is quantized to Levels steps with a threshold offset that is constant within each cell of a Pattern scale grid and random from cell to cell (a hashed white-noise dither, not an ordered Bayer matrix despite the file name). Alpha is passed through. Quantizes the straight (unpremultiplied) colour and premultiplies the result again. The quantized colour is clamped to [0, 1]; the output is rgba16f like the other volume filters.",
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
      "NAME": "levels",
      "TYPE": "long",
      "DEFAULT": 2,
      "MIN": 2,
      "MAX": 8,
      "LABEL": "Levels"
    },
    {
      "NAME": "patternScale",
      "TYPE": "float",
      "DEFAULT": 16.0,
      "MIN": 4.0,
      "MAX": 64.0,
      "LABEL": "Pattern scale"
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

vec3 unpremultiply(vec4 c){ return c.a > 0.0 ? c.rgb / c.a : vec3(0.0); }

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec4 s = texture(volIn, p);
    vec3 cell = floor(p * patternScale);
    float t = hash13(cell);   // pseudo-Bayer [0,1)
    float n = float(levels);
    vec3 q = floor(unpremultiply(s)*n + t)/n;
    imageStore(volOut, pos, vec4(clamp(q, 0.0, 1.0) * s.a, s.a));

}
