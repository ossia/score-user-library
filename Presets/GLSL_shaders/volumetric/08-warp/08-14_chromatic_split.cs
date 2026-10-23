/*{
  "DESCRIPTION": "Per-channel offset (chromatic aberration) \u2014 R/G/B sampled at different spatial offsets. Glitch-VJ staple. Alpha is the maximum of the three shifted samples' alpha. Premultiplied volumes stay premultiplied (each channel is at most the alpha it came with). The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "WARP"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "amount",
      "TYPE": "float",
      "DEFAULT": 0.015,
      "MIN": 0.0,
      "MAX": 0.1,
      "LABEL": "Amount"
    },
    {
      "NAME": "direction",
      "TYPE": "point3d",
      "DEFAULT": [
        1.0,
        0.0,
        0.0
      ],
      "MIN": [
        -1.0,
        -1.0,
        -1.0
      ],
      "MAX": [
        1.0,
        1.0,
        1.0
      ],
      "LABEL": "Direction"
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

    vec3 d = normalize(direction+1e-6) * amount;
    vec4 sr = texture(volIn, p - d);
    vec4 sg = texture(volIn, p    );
    vec4 sb = texture(volIn, p + d);
    // Alpha covers all three shifted copies, so a density volume keeps its fringes.
    imageStore(volOut, pos, vec4(sr.r, sg.g, sb.b, max(sr.a, max(sg.a, sb.a))));

}
