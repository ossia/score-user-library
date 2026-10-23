/*{
  "DESCRIPTION": "3D cel-shade: quantize the voxel luminance into a small number of bands. Cartoon look. Luminance is taken on the straight (unpremultiplied) colour and the result is premultiplied again. The output is rgba16f, so HDR colour is not clipped.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "STYLIZE"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "bands",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 2,
      "MAX": 8,
      "LABEL": "Bands"
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
    vec3 c = unpremultiply(s);
    float L = dot(c, vec3(0.2126, 0.7152, 0.0722));
    float n = float(bands);
    float Lq = floor(L*n)/n;
    vec3 col = c * (Lq / max(L, 1e-3)) * s.a;
    imageStore(volOut, pos, vec4(col, s.a));

}
