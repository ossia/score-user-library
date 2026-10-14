/*{
  "DESCRIPTION": "Slice grid / contact sheet: tile N \u00d7 N equally-spaced slices of the volume as a 2D grid. Great for debugging. Shows the stored (premultiplied) colour opaque, i.e. the volume composited over black; the alpha is not shown.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
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
      "NAME": "tilesPerSide",
      "TYPE": "long",
      "DEFAULT": 8,
      "MIN": 2,
      "MAX": 16,
      "LABEL": "Tiles per side"
    },
    {
      "NAME": "axis",
      "TYPE": "long",
      "DEFAULT": 2,
      "VALUES": [
        0,
        1,
        2
      ],
      "LABELS": [
        "X",
        "Y",
        "Z"
      ],
      "LABEL": "Slicing axis"
    }
  ]
}*/

void main()
{
    vec2 uv = isf_FragNormCoord;
    float n = float(tilesPerSide);
    vec2 tile = floor(uv * n);
    vec2 local = fract(uv * n);
    float idx = tile.y * n + tile.x;
    float s = (idx + 0.5) / (n*n);
    vec3 p;
    if(axis == 0) p = vec3(s, local.x, local.y);
    else if(axis == 1) p = vec3(local.x, s, local.y);
    else p = vec3(local.x, local.y, s);
    // Show the slice opaque: the volume's alpha is data (a density, |grad|,
    // a simulation channel), and passing it through as frame alpha made
    // low-alpha volumes disappear once composited.
    isf_FragColor = vec4(textureLod(volume, p, 0.0).rgb, 1.0);
}
