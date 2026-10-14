/*{
  "DESCRIPTION": "3D dilation (max filter, 3x3x3): inflates bright regions. The input is read texel by texel as a 3D texture of any format, so signed and HDR volumes (01-15 curl noise, the rgba16f simulations, 07-06 Laplacian...) are filtered per channel without clipping; the output is rgba16f.",
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

    vec4 m = texelFetch(volIn, pos, 0);
    for(int k=-1;k<=1;k++)
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++){
        ivec3 q = clamp(pos + ivec3(i,j,k), ivec3(0), size-1);
        m = max(m, texelFetch(volIn, q, 0));
    }
    imageStore(volOut, pos, m);

}
