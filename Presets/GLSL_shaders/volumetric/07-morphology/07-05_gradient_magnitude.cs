/*{
  "DESCRIPTION": "Compute gradient magnitude |\u2207V| via central differences. Highlights isosurfaces / material boundaries \u2014 x-ray feel. The magnitude (times the grid size) is not clamped and is stored in rgba16f, so steep gradients stay above 1 instead of saturating.",
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
    vec3 c0 = (vec3(pos)+0.5)*invSize;
    float xm = texture(volIn, c0 - vec3(invSize.x,0,0)).r;
    float xp = texture(volIn, c0 + vec3(invSize.x,0,0)).r;
    float ym = texture(volIn, c0 - vec3(0,invSize.y,0)).r;
    float yp = texture(volIn, c0 + vec3(0,invSize.y,0)).r;
    float zm = texture(volIn, c0 - vec3(0,0,invSize.z)).r;
    float zp = texture(volIn, c0 + vec3(0,0,invSize.z)).r;
    vec3 g = 0.5 * vec3(xp-xm, yp-ym, zp-zm);
    float mag = length(g) * float(size.x); // scale by grid size
    imageStore(volOut, pos, vec4(vec3(mag), 1.0));

}
