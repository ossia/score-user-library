/*{
  "DESCRIPTION": "Min / max combinator: union (max) or intersection (min) of two density fields. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COMPOSITE"
  ],
  "RESOURCES": [
    {
      "NAME": "A",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "A"
    },
    {
      "NAME": "B",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "B"
    },
    {
      "NAME": "useMin",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Min (else max)"
    },
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
    imageStore(volOut, pos, useMin ? min(a, b) : max(a, b));
}
