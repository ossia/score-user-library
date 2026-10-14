/*{
  "DESCRIPTION": "Minimal / teaching viewer: a fixed orthographic view straight down +Z, one screen pixel per ray, in a few lines of code. For a free camera use 18-06_orbit_raymarch (emission) or 18-10_orbit_iso_raymarch (isosurface). Isosurface raymarch with Lambertian shading: march until the density crosses an iso value, then shade with \u2207V as normal. Solid-looking rendering of density fields (red channel). The surface is opaque Tint, the rest of the frame is transparent.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "CATEGORIES": [
    "3D-VIEWER-MINIMAL"
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
      "MAX": 384,
      "LABEL": "Steps"
    },
    {
      "NAME": "iso",
      "TYPE": "float",
      "DEFAULT": 0.4,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Iso"
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
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        0.8,
        0.5,
        1.0
      ],
      "LABEL": "Tint"
    }
  ]
}*/

void main()
{
    vec2 uv = isf_FragNormCoord;
    int N = int(steps);
    vec3 L = normalize(lightDir + 1e-6);
    vec3 e = 1.0 / vec3(textureSize(volume, 0));
    vec4 outCol = vec4(0.0);
    float prev = textureLod(volume, vec3(uv, 0.0), 0.0).r;
    for(int i=1; i<N; i++){
        float z = float(i)/float(N);
        vec3 p = vec3(uv, z);
        float cur = textureLod(volume, p, 0.0).r;
        if((prev - iso) * (cur - iso) < 0.0){
            // Bisection refine one step
            float t = (iso - prev) / max(cur - prev, 1e-5);
            vec3 hit = vec3(uv, (float(i-1) + t)/float(N));
            // Gradient
            vec3 g = vec3(
                textureLod(volume, hit + vec3(e.x,0,0), 0.0).r - textureLod(volume, hit - vec3(e.x,0,0), 0.0).r,
                textureLod(volume, hit + vec3(0,e.y,0), 0.0).r - textureLod(volume, hit - vec3(0,e.y,0), 0.0).r,
                textureLod(volume, hit + vec3(0,0,e.z), 0.0).r - textureLod(volume, hit - vec3(0,0,e.z), 0.0).r);
            vec3 n = -normalize(g + 1e-6);
            float nl = max(dot(n, L), 0.0);
            outCol = vec4(tint.rgb * (0.15 + 0.85*nl), 1.0);
            break;
        }
        prev = cur;
    }
    isf_FragColor = outCol;
}
