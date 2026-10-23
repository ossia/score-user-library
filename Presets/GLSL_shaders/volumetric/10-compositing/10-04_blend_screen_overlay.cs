/*{
  "DESCRIPTION": "Photoshop-style blend modes, volumetric: Screen / Overlay / Dodge / Burn. Both inputs are premultiplied: the mode is applied to their straight colours where they overlap and composited like the W3C blend modes (A (1 - B.a) + B (1 - A.a) + A.a B.a mode(A, B)), alpha is the union of the two (A.a + B.a (1 - A.a)). With opaque inputs this is the plain blend mode. The modes are defined on [0, 1] colour and clamped; the output is rgba16f like the other volume filters.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COMPOSITE"
  ],
  "RESOURCES": [
    {
      "NAME": "A",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "A"
    },
    {
      "NAME": "B",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "B"
    },
    {
      "NAME": "mode",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [
        0,
        1,
        2,
        3
      ],
      "LABELS": [
        "Screen",
        "Overlay",
        "Dodge",
        "Burn"
      ],
      "LABEL": "Mode"
    },
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_A",
      "HEIGHT": "$HEIGHT_A",
      "DEPTH": "$DEPTH_A"
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
    vec3 p = (vec3(pos)+0.5)/vec3(size);
    vec4 sa = texture(A, p);
    vec4 sb = texture(B, p);
    vec3 a = unpremultiply(sa);
    vec3 b = unpremultiply(sb);
    vec3 o;
    if(mode == 0){ o = 1.0 - (1.0 - a)*(1.0 - b); }
    else if(mode == 1){
        vec3 lo = 2.0*a*b;
        vec3 hi = 1.0 - 2.0*(1.0-a)*(1.0-b);
        o = mix(lo, hi, step(0.5, a));
    }
    else if(mode == 2){ o = a / max(1.0 - b, vec3(1e-3)); }
    else              { o = 1.0 - (1.0 - a)/max(b, vec3(1e-3)); }
    vec3 rgb = sa.rgb * (1.0 - sb.a) + sb.rgb * (1.0 - sa.a) + sa.a * sb.a * clamp(o, 0.0, 1.0);
    imageStore(volOut, pos, vec4(rgb, sa.a + sb.a * (1.0 - sa.a)));
}
