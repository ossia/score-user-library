/*{
  "DESCRIPTION": "Pseudo-lighting bake: compute a normal from \u2207V and shade with a Lambertian lobe. Turns a density field into a lit colorized volume in a single pass. Colour is premultiplied (alpha = density) and can exceed 1 (ambient + diffuse), so the output is rgba16f.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COLOR"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "lightDir",
      "TYPE": "point3d",
      "DEFAULT": [
        0.6,
        0.7,
        0.4
      ],
      "MIN": [
        -1,
        -1,
        -1
      ],
      "MAX": [
        1,
        1,
        1
      ],
      "LABEL": "Light direction"
    },
    {
      "NAME": "diffuse",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        0.75,
        0.4,
        1.0
      ],
      "LABEL": "Diffuse color"
    },
    {
      "NAME": "ambient",
      "TYPE": "color",
      "DEFAULT": [
        0.1,
        0.12,
        0.2,
        1.0
      ],
      "LABEL": "Ambient color"
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
    vec3 c0 = p;
    float xm = texture(volIn, c0 - vec3(invSize.x,0,0)).r;
    float xp = texture(volIn, c0 + vec3(invSize.x,0,0)).r;
    float ym = texture(volIn, c0 - vec3(0,invSize.y,0)).r;
    float yp = texture(volIn, c0 + vec3(0,invSize.y,0)).r;
    float zm = texture(volIn, c0 - vec3(0,0,invSize.z)).r;
    float zp = texture(volIn, c0 + vec3(0,0,invSize.z)).r;
    vec3 g = vec3(xp-xm, yp-ym, zp-zm);
    vec3 n = -normalize(g + 1e-6);
    float nl = max(dot(n, normalize(lightDir+1e-6)), 0.0);
    float density = texture(volIn, p).r;
    vec3 col = (ambient.rgb + diffuse.rgb * nl) * density;
    imageStore(volOut, pos, vec4(col, density));

}
