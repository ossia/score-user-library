/*{
  "DESCRIPTION": "3D median: in a 3x3x3 neighborhood (27 voxels) take the luminance-sorted median. Salt-and-pepper removal; painterly look on noisy volumes. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "BLUR"
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
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec3 invSize = 1.0 / vec3(size);
    // Collect 27 samples with their luminance
    vec4 samples[27];
    float lum[27];
    int idx = 0;
    for(int k=-1;k<=1;k++)
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++){
        vec3 uvw = (vec3(pos)+0.5+vec3(i,j,k))*invSize;
        vec4 s = texture(volIn, uvw);
        samples[idx] = s;
        lum[idx] = dot(s.rgb, vec3(0.2126, 0.7152, 0.0722));
        idx++;
    }
    // Partial sort: find the 14th smallest (median of 27)
    // Simple selection: for each slot in first 14, find min in rest
    for(int a=0; a<14; a++){
        int m = a;
        for(int b=a+1; b<27; b++) if(lum[b] < lum[m]) m = b;
        float tf = lum[a]; lum[a] = lum[m]; lum[m] = tf;
        vec4 ts = samples[a]; samples[a] = samples[m]; samples[m] = ts;
    }
    imageStore(volOut, pos, samples[13]);

}
