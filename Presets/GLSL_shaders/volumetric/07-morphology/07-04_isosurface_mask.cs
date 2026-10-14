/*{
  "DESCRIPTION": "Soft isosurface mask: outputs smoothstep around a threshold. Produces a filled shell at iso-value. The input is read at full precision; the output is rgba16f like the other volume filters, so the mask's soft edge is not quantized to 8 bits before a viewer or a later filter interpolates it.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "MORPHOLOGY"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "iso",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Iso-value"
    },
    {
      "NAME": "width",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.001,
      "MAX": 0.5,
      "LABEL": "Shell width"
    }
  ],
  "RESOURCES": [
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

    vec3 invSize = 1.0 / vec3(size);
    vec4 s = texture(volIn, (vec3(pos)+0.5)*invSize);
    float v = s.r;
    float mask = 1.0 - smoothstep(width*0.5, width, abs(v - iso));
    imageStore(volOut, pos, vec4(vec3(mask), 1.0));

}
