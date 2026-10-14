/*{
  "DESCRIPTION": "Schlieren / gradient visualization: operate on an existing 3D volume and output its gradient vector encoded as RGB. Used as an input to downstream warps for wind-tunnel aesthetics. The gradient is stored as RGB = 0.5 + g N / 2 (N = the volume width; 0.5 = no gradient), unclamped in rgba16f, the encoding 11-02 advect reads by default; alpha = |g|. This is a vector field, not colour: it is not premultiplied.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "EXOTIC"
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
    vec3 c0 = p;
    float xm = texture(volIn, c0 - vec3(invSize.x,0,0)).r;
    float xp = texture(volIn, c0 + vec3(invSize.x,0,0)).r;
    float ym = texture(volIn, c0 - vec3(0,invSize.y,0)).r;
    float yp = texture(volIn, c0 + vec3(0,invSize.y,0)).r;
    float zm = texture(volIn, c0 - vec3(0,0,invSize.z)).r;
    float zp = texture(volIn, c0 + vec3(0,0,invSize.z)).r;
    vec3 g = 0.5 * vec3(xp-xm, yp-ym, zp-zm);
    vec3 col = g * float(size.x) * 0.5 + 0.5;
    imageStore(volOut, pos, vec4(col, length(g)));

}
