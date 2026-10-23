/*{
  "DESCRIPTION": "Separable 3D Gaussian blur in three passes (X, then Y, then Z). Sigma is in voxels; the kernel reaches 3 sigma on each side (up to 18 voxels), so cost grows linearly with Sigma. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
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
      "NAME": "sigma",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.5,
      "MAX": 6.0,
      "LABEL": "Sigma"
    },
    {
      "NAME": "blurTmp1",
      "TYPE": "image",
      "ACCESS": "read_write",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn"
    },
    {
      "NAME": "blurTmp2",
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
        "TARGET": "blurTmp1"
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
        "TARGET": "blurTmp2"
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

const int KMAX = 18;

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 sz = imageSize(volOut);
    if(any(greaterThanEqual(pos, sz))) return;
    vec3 invSize = 1.0 / vec3(sz);

    // Kernel radius 3 sigma (99.7% of the weight), capped at KMAX taps each side.
    float s2 = max(sigma*sigma, 1e-4);
    int R = min(int(ceil(3.0 * sigma)), KMAX);
    float norm = 0.0;
    vec4 acc = vec4(0.0);
    for(int i=-R;i<=R;i++){
        float w = exp(-float(i*i)/(2.0*s2));
        norm += w;
        if(PASSINDEX == 0)
            acc += w * texture(volIn, (vec3(pos) + 0.5 + vec3(i,0,0)) * invSize);
        else if(PASSINDEX == 1)
            acc += w * imageLoad(blurTmp1, clamp(pos + ivec3(0,i,0), ivec3(0), sz-1));
        else
            acc += w * imageLoad(blurTmp2, clamp(pos + ivec3(0,0,i), ivec3(0), sz-1));
    }
    acc /= norm;
    if(PASSINDEX == 0) imageStore(blurTmp1, pos, acc);
    else if(PASSINDEX == 1) imageStore(blurTmp2, pos, acc);
    else imageStore(volOut, pos, acc);
}
