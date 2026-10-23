/*{
  "DESCRIPTION": "Inigo Quilez cosine palette: tint a scalar density into vivid color bands. Cheapest way to make a VJ-looking volume. The palette is evaluated on the stored red channel and the result is premultiplied by the input's alpha. Negative palette values are cut to 0; values above 1 (large B) are kept in the rgba16f output (see 09-10 tone mapping).",
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
      "NAME": "A",
      "TYPE": "color",
      "DEFAULT": [
        0.5,
        0.5,
        0.5,
        1.0
      ],
      "LABEL": "A (base)"
    },
    {
      "NAME": "B",
      "TYPE": "color",
      "DEFAULT": [
        0.5,
        0.5,
        0.5,
        1.0
      ],
      "LABEL": "B (amp)"
    },
    {
      "NAME": "C",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        1.0,
        1.0,
        1.0
      ],
      "LABEL": "C (freq)"
    },
    {
      "NAME": "D",
      "TYPE": "color",
      "DEFAULT": [
        0.0,
        0.33,
        0.67,
        1.0
      ],
      "LABEL": "D (phase)"
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

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d){
    return a + b * cos(6.28318530718 * (c*t + d));
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec4 s = texture(volIn, p);
    float t = s.r;
    vec3 col = palette(t, A.rgb, B.rgb, C.rgb, D.rgb);
    imageStore(volOut, pos, vec4(max(col, 0.0) * s.a, s.a));

}
