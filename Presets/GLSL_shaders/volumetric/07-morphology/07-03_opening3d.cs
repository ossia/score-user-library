/*{
  "DESCRIPTION": "Morphological opening: erode then dilate. Removes small bright features while preserving large ones. Two passes through an intermediate image. The input is read texel by texel as a 3D texture of any format, so signed and HDR volumes (01-15 curl noise, the rgba16f simulations, 07-06 Laplacian...) are filtered per channel without clipping; the output is rgba16f.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "MORPHOLOGY"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "morphTmp",
      "TYPE": "image",
      "ACCESS": "read_write",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn"
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
        "TARGET": "morphTmp"
      }
    },
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
    ivec3 sz = imageSize(volOut);
    if(any(greaterThanEqual(pos, sz))) return;
    if(PASSINDEX == 0){
        // Erode volIn -> morphTmp
        vec4 m = texelFetch(volIn, pos, 0);
        for(int k=-1;k<=1;k++)
        for(int j=-1;j<=1;j++)
        for(int i=-1;i<=1;i++){
            ivec3 q = clamp(pos + ivec3(i,j,k), ivec3(0), sz-1);
            m = min(m, texelFetch(volIn, q, 0));
        }
        imageStore(morphTmp, pos, m);
    } else {
        // Dilate morphTmp -> volOut
        vec4 m = imageLoad(morphTmp, pos);
        for(int k=-1;k<=1;k++)
        for(int j=-1;j<=1;j++)
        for(int i=-1;i<=1;i++){
            ivec3 q = clamp(pos + ivec3(i,j,k), ivec3(0), sz-1);
            m = max(m, imageLoad(morphTmp, q));
        }
        imageStore(volOut, pos, m);
    }
}
