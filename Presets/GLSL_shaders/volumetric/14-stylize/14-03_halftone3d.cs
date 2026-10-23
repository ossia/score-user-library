/*{
  "DESCRIPTION": "3D halftone: compare density to a 3D threshold pattern \u2014 stippled voxel look. Dot size follows the luminance of the stored (premultiplied) colour, so thin density makes small dots; the dots keep the input colour. The output is rgba16f, so HDR colour is not clipped.",
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
      "NAME": "dotsPerSide",
      "TYPE": "float",
      "DEFAULT": 32.0,
      "MIN": 4.0,
      "MAX": 128.0,
      "LABEL": "Dots / side"
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

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec4 s = texture(volIn, p);
    float L = dot(s.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 g = p * dotsPerSide;
    vec3 f = fract(g) - 0.5;
    float d = length(f);
    float thresh = 0.5 * sqrt(L);
    float v = step(d, thresh);
    imageStore(volOut, pos, vec4(s.rgb * v, s.a));

}
