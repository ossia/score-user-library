/*{
  "DESCRIPTION": "Simple levels, per channel on the straight (unpremultiplied) colour: In black / In white remap the input range to [0,1] (clamped), then Gamma bends the midtones (above 1 brightens); the result is premultiplied again. Alpha is passed through. The result is clamped to [0, 1]; the output is rgba16f like the other volume filters, so a gamma curve does not band.",
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
      "NAME": "gamma",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.2,
      "MAX": 4.0,
      "LABEL": "Gamma"
    },
    {
      "NAME": "inBlack",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 0.5,
      "LABEL": "In black"
    },
    {
      "NAME": "inWhite",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.5,
      "MAX": 1.0,
      "LABEL": "In white"
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
    vec3 r = clamp((unpremultiply(s) - inBlack) / max(inWhite - inBlack, 1e-4), 0.0, 1.0);
    r = pow(r, vec3(1.0/max(gamma, 1e-3)));
    imageStore(volOut, pos, vec4(r * s.a, s.a));

}
