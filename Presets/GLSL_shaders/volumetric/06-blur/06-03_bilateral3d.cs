/*{
  "DESCRIPTION": "Bilateral blur \u2014 edge-preserving 3D smoothing. Weights combine spatial distance and color similarity. Fixed 5x5x5 window, so Sigma (space) above about 2 voxels flattens towards a box weight. Heavy but gorgeous. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "BLUR"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "sigmaSpace",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.5,
      "MAX": 4.0,
      "LABEL": "Sigma (space)"
    },
    {
      "NAME": "sigmaColor",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.01,
      "MAX": 1.0,
      "LABEL": "Sigma (color)"
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

    vec3 invSize = 1.0 / vec3(size);
    vec4 center = texture(volIn, (vec3(pos)+0.5)*invSize);
    vec4 acc = vec4(0.0);
    float W = 0.0;
    float ss = sigmaSpace*sigmaSpace;
    float sc = sigmaColor*sigmaColor;
    const int R = 2;
    for(int k=-R;k<=R;k++)
    for(int j=-R;j<=R;j++)
    for(int i=-R;i<=R;i++){
        vec3 uvw = (vec3(pos)+0.5+vec3(i,j,k))*invSize;
        vec4 s = texture(volIn, uvw);
        float ws = exp(-float(i*i+j*j+k*k)/(2.0*ss));
        float wc = exp(-dot(s-center,s-center)/(2.0*sc));
        acc += ws*wc*s;
        W   += ws*wc;
    }
    imageStore(volOut, pos, acc/max(W,1e-6));

}
