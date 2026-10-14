/*{
  "DESCRIPTION": "Per-axis color ramp: tint the volume by the sum of three axis-aligned colour ramps. Each axis contributes a color that interpolates from its negative to positive end. Produces crystalline, directional lighting-like tinting without any gradient evaluation. Premultiplied volumes stay premultiplied. The output is rgba16f, so HDR input colour is not clipped.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COLOR"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "xNeg",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        0.2,
        0.2,
        1.0
      ],
      "LABEL": "X-"
    },
    {
      "NAME": "xPos",
      "TYPE": "color",
      "DEFAULT": [
        0.2,
        1.0,
        1.0,
        1.0
      ],
      "LABEL": "X+"
    },
    {
      "NAME": "yNeg",
      "TYPE": "color",
      "DEFAULT": [
        0.1,
        0.1,
        0.3,
        1.0
      ],
      "LABEL": "Y-"
    },
    {
      "NAME": "yPos",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        1.0,
        0.8,
        1.0
      ],
      "LABEL": "Y+"
    },
    {
      "NAME": "zNeg",
      "TYPE": "color",
      "DEFAULT": [
        0.3,
        0.1,
        0.5,
        1.0
      ],
      "LABEL": "Z-"
    },
    {
      "NAME": "zPos",
      "TYPE": "color",
      "DEFAULT": [
        0.5,
        1.0,
        0.3,
        1.0
      ],
      "LABEL": "Z+"
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

    vec4 s = texture(volIn, p);
    vec3 xR = mix(xNeg.rgb, xPos.rgb, p.x);
    vec3 yR = mix(yNeg.rgb, yPos.rgb, p.y);
    vec3 zR = mix(zNeg.rgb, zPos.rgb, p.z);
    vec3 col = (xR + yR + zR) / 3.0;
    imageStore(volOut, pos, vec4(col * s.rgb, s.a));

}
