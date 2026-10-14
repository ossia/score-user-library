/*{
  "DESCRIPTION": "Raymarch with a transfer function: density \u2192 cosine-palette color, then front-to-back composite. A quick way to colorize scalar volumes. The output is premultiplied (colour already weighted by the accumulated opacity), transparent where the ray meets no density.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "ALPHA": "premultiplied",
  "CATEGORIES": [
    "3D-VIEWER"
  ],
  "INPUTS": [
    {
      "NAME": "volume",
      "TYPE": "image",
      "DIMENSIONS": 3,
      "LABEL": "Volume"
    },
    {
      "NAME": "steps",
      "TYPE": "long",
      "DEFAULT": 128,
      "MIN": 32,
      "MAX": 256,
      "LABEL": "Steps"
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.1,
      "MAX": 16.0,
      "LABEL": "Density"
    },
    {
      "NAME": "A",
      "TYPE": "color",
      "DEFAULT": [
        0.5,
        0.5,
        0.5,
        1.0
      ],
      "LABEL": "A"
    },
    {
      "NAME": "B",
      "TYPE": "color",
      "DEFAULT": [
        0.5,
        0.5,
        0.5,
        1.0
      ],
      "LABEL": "B"
    },
    {
      "NAME": "C",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        1.0,
        1.0,
        1.0
      ],
      "LABEL": "C"
    },
    {
      "NAME": "D",
      "TYPE": "color",
      "DEFAULT": [
        0.0,
        0.33,
        0.67,
        1.0
      ],
      "LABEL": "D"
    }
  ]
}*/

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d){
    return a + b * cos(6.28318530718 * (c*t + d));
}

void main()
{
    vec2 uv = isf_FragNormCoord;
    int N = int(steps);
    vec3 acc = vec3(0.0);
    float trans = 1.0;
    for(int i=0; i<N; i++){
        float z = (float(i)+0.5)/float(N);
        vec4 s = textureLod(volume, vec3(uv, z), 0.0);
        float v = s.r;
        vec3 col = palette(v, A.rgb, B.rgb, C.rgb, D.rgb);
        float a = clamp(v * density / float(N) * 32.0, 0.0, 1.0);
        acc += trans * col * a;
        trans *= (1.0 - a);
        if(trans < 0.002) break;
    }
    isf_FragColor = vec4(acc, 1.0 - trans);
}
