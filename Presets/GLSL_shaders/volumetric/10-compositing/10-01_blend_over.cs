/*{
  "DESCRIPTION": "Porter-Duff 'over' for premultiplied volumes: A over B, out = A + B (1 - A.a) on all four channels. The volume generators that carry a colour and a density (02-24, 09-07, 04-06, 15-xx...) store colour already multiplied by alpha, which is what this expects. A volume with alpha 1 everywhere (most scalar generators) is opaque and simply replaces B. The output is rgba16f, so HDR colour passes through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COMPOSITE"
  ],
  "INPUTS": [
    {
      "NAME": "A",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "A (top)"
    },
    {
      "NAME": "B",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "B (below)"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_A",
      "HEIGHT": "$HEIGHT_A",
      "DEPTH": "$DEPTH_A"
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
    vec3 p = (vec3(pos)+0.5)/vec3(size);
    vec4 a = texture(A, p);
    vec4 b = texture(B, p);
    vec4 o;
    o.rgb = a.rgb + b.rgb * (1.0 - a.a);
    o.a   = a.a   + b.a   * (1.0 - a.a);
    imageStore(volOut, pos, o);
}
