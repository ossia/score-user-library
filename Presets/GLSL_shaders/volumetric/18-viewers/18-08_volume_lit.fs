/*{
  "DESCRIPTION": "Lit volumetric raymarch: at each step, additionally sample the volume along a shadow ray toward the light to get per-sample transmittance. The output is premultiplied (colour already weighted by the accumulated opacity), transparent where the ray meets no density. Volumes store premultiplied colour; each sample's colour is unpremultiplied (divided by its alpha) before lighting, so thin fog keeps its colour instead of being darkened twice.",
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
      "DEFAULT": 96,
      "MIN": 32,
      "MAX": 192,
      "LABEL": "Primary steps"
    },
    {
      "NAME": "shadowSteps",
      "TYPE": "long",
      "DEFAULT": 12,
      "MIN": 4,
      "MAX": 32,
      "LABEL": "Shadow steps"
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.1,
      "MAX": 16.0,
      "LABEL": "Density"
    },
    {
      "NAME": "lightDir",
      "TYPE": "point3d",
      "DEFAULT": [
        0.7,
        0.9,
        -0.6
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
      "LABEL": "Light dir"
    },
    {
      "NAME": "lightCol",
      "TYPE": "color",
      "DEFAULT": [
        1.2,
        0.95,
        0.7,
        1.0
      ],
      "LABEL": "Light color"
    }
  ]
}*/

vec3 straightColor(vec4 s){ return s.a > 0.0 ? s.rgb / s.a : s.rgb; }

void main()
{
    vec2 uv = isf_FragNormCoord;
    vec3 L = normalize(lightDir + 1e-6);
    int N = int(steps), Ns = int(shadowSteps);
    float invN = 1.0/float(N), invNs = 1.0/float(Ns);
    vec3 acc = vec3(0.0);
    float trans = 1.0;
    for(int i=0; i<N; i++){
        float z = (float(i)+0.5)*invN;
        vec3 p = vec3(uv, z);
        vec4 s = textureLod(volume, p, 0.0);
        float a = clamp(s.a * density * invN * 32.0, 0.0, 1.0);
        // shadow ray
        float st = 1.0;
        for(int j=1; j<=Ns; j++){
            vec3 sp = clamp(p + L * float(j)*invNs, 0.0, 1.0);
            float sa = clamp(textureLod(volume, sp, 0.0).a * density * invNs, 0.0, 1.0);
            st *= (1.0 - sa);
        }
        vec3 lit = straightColor(s) * (0.25 + 0.75*st) * lightCol.rgb;
        acc += trans * lit * a;
        trans *= (1.0 - a);
        if(trans < 0.002) break;
    }
    isf_FragColor = vec4(acc, 1.0 - trans);
}
