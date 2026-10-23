/*{
  "DESCRIPTION": "3D LUT color grading. Use the input volume's RGB as a 3D coordinate into a lookup volume (the `lut` input). Standard color-grading primitive (.cube files, Resolve LUTs etc. can be baked into a 3D texture). Most powerful colour op in the catalogue. The LUT is indexed with the straight (unpremultiplied) colour and the result is premultiplied again; the output is rgba16f, since Mix below 1 keeps part of an HDR input.",
  "CREDIT": "ossia 3D catalog. J. Selan, Using Lookup Tables to Accelerate Color Transformations, GPU Gems 2 ch. 24, 2005.",
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
      "NAME": "lut",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "3D LUT"
    },
    {
      "NAME": "mixAmt",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "LUT mix"
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
    // Texel-centre remap so 0 and 1 hit the first and last LUT entries
    // exactly (Selan, GPU Gems 2 ch. 24).
    vec3 n = vec3(textureSize(lut, 0));
    vec3 lc = clamp(c, 0.0, 1.0) * (n - 1.0) / n + 0.5 / n;
    vec3 graded = texture(lut, lc).rgb;
    vec3 col = mix(c, graded, mixAmt);
    imageStore(volOut, pos, vec4(col * s.a, s.a));

}
