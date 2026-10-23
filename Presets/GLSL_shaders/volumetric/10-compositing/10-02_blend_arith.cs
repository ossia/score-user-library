/*{
  "DESCRIPTION": "Arithmetic blend: add / subtract / multiply / divide two 3D volumes. Not clamped: subtract can go negative and add above 1, which the rgba16f output keeps (follow with 09-06 Levels to clip). On premultiplied colour volumes add, subtract and multiply stay premultiplied.",
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
      "NAME": "op",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [
        0,
        1,
        2,
        3
      ],
      "LABELS": [
        "Add",
        "Sub",
        "Mul",
        "Div"
      ],
      "LABEL": "Op"
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
    vec4 o;
    if(op == 0) o = a + b;
    else if(op == 1) o = a - b;
    else if(op == 2) o = a * b;
    else o = a / max(b, vec4(1e-4));
    imageStore(volOut, pos, o);
}
