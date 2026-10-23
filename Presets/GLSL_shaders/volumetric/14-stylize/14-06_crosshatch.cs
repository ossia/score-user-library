/*{
  "DESCRIPTION": "3D cross-hatching: render the volume as directional line patterns where line density is proportional to (1 - luminance). Four hatch directions at successive luminance thresholds. Pencil-sketch look. Luminance is that of the straight (unpremultiplied) colour; the paper / ink colour is premultiplied by the input alpha. The output is rgba16f like the other volume filters (it only holds the two picked colours, weighted by the input's alpha).",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "STYLIZE"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "hatchScale",
      "TYPE": "float",
      "DEFAULT": 24.0,
      "MIN": 4.0,
      "MAX": 96.0,
      "LABEL": "Hatch scale"
    },
    {
      "NAME": "inkColor",
      "TYPE": "color",
      "DEFAULT": [
        0.0,
        0.0,
        0.0,
        1.0
      ],
      "LABEL": "Ink"
    },
    {
      "NAME": "paperColor",
      "TYPE": "color",
      "DEFAULT": [
        0.95,
        0.92,
        0.85,
        1.0
      ],
      "LABEL": "Paper"
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

vec3 unpremultiply(vec4 c){ return c.a > 0.0 ? c.rgb / c.a : vec3(0.0); }

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec4 s = texture(volIn, p);
    float L = dot(unpremultiply(s), vec3(0.2126, 0.7152, 0.0722));
    float dark = 1.0 - L;
    vec3 q = p * hatchScale;
    // Four hatch directions
    float h1 = abs(mod(q.x + q.y + q.z, 1.0) - 0.5);
    float h2 = abs(mod(q.x - q.y + q.z, 1.0) - 0.5);
    float h3 = abs(mod(q.x + q.y - q.z, 1.0) - 0.5);
    float h4 = abs(mod(-q.x + q.y + q.z, 1.0) - 0.5);
    float hatchCoverage = 0.0;
    if(dark > 0.2) hatchCoverage = max(hatchCoverage, step(h1, 0.15));
    if(dark > 0.4) hatchCoverage = max(hatchCoverage, step(h2, 0.15));
    if(dark > 0.6) hatchCoverage = max(hatchCoverage, step(h3, 0.15));
    if(dark > 0.8) hatchCoverage = max(hatchCoverage, step(h4, 0.15));
    vec3 col = mix(paperColor.rgb, inkColor.rgb, hatchCoverage);
    imageStore(volOut, pos, vec4(col * s.a, s.a));

}
