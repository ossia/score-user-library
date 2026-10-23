/*{
  "DESCRIPTION": "Posterize / quantize: step each colour channel of the straight (unpremultiplied) colour into Levels evenly spaced values from 0 to 1 (black and full white both kept), then premultiply again. Alpha is passed through. The output is rgba16f like the other volume filters (every level lies in [0, 1]).",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COLOR"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "levels",
      "TYPE": "long",
      "DEFAULT": 6,
      "MIN": 2,
      "MAX": 16,
      "LABEL": "Levels"
    },
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

vec3 unpremultiply(vec4 c){ return c.a > 0.0 ? c.rgb / c.a : vec3(0.0); }

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec4 s = texture(volIn, p);
    float n = float(levels);
    vec3 c = clamp(min(floor(unpremultiply(s)*n), n - 1.0) / (n - 1.0), 0.0, 1.0);
    imageStore(volOut, pos, vec4(c * s.a, s.a));

}
