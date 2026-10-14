/*{
  "DESCRIPTION": "Minimal / teaching viewer: a fixed orthographic view straight down +Z, one screen pixel per ray, in a few lines of code. For a free camera use 18-06_orbit_raymarch (emission) or 18-10_orbit_iso_raymarch (isosurface). Emission-absorption raymarch: front-to-back Beer-Lambert accumulation over the volume's density (in alpha channel). Standard volumetric smoke/haze look. The output is premultiplied (colour already weighted by the accumulated opacity), transparent where the ray meets no density, so it composites over whatever lies under it. Volumes store premultiplied colour; each sample's colour is unpremultiplied (divided by its alpha) before it is weighted by the step opacity, so thin fog keeps its colour instead of being darkened twice.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "ALPHA": "premultiplied",
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
      "DEFAULT": 192,
      "MIN": 32,
      "MAX": 512,
      "LABEL": "Steps"
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.1,
      "MAX": 16.0,
      "LABEL": "Density"
    }
  ]
}*/

vec3 straightColor(vec4 s){ return s.a > 0.0 ? s.rgb / s.a : s.rgb; }

void main()
{
    vec2 uv = isf_FragNormCoord;
    int N = int(steps);
    vec3 acc = vec3(0.0);
    float trans = 1.0;
    for(int i=0; i<N; i++){
        float z = float(i)/float(N);
        vec4 s = textureLod(volume, vec3(uv, z), 0.0);
        float a = clamp(s.a * density / float(N) * 32.0, 0.0, 1.0);
        acc += trans * straightColor(s) * a;
        trans *= (1.0 - a);
        if(trans < 0.001) break;
    }
    isf_FragColor = vec4(acc, 1.0 - trans);
}
