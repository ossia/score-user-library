/*{
  "DESCRIPTION": "Slice viewer: sample the 3D volume at a chosen Z (or X, Y) slice and display the 2D slice across the frame. Shows the stored (premultiplied) colour opaque, i.e. the volume composited over black; the alpha is not shown.",
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
      "NAME": "slice",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Slice position"
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
      "LABEL": "Axis"
    }
  ]
}*/

void main()
{
    vec2 uv = isf_FragNormCoord;
    vec3 p;
    if(axis == 0) p = vec3(slice, uv.x, uv.y);
    else if(axis == 1) p = vec3(uv.x, slice, uv.y);
    else p = vec3(uv.x, uv.y, slice);
    // Show the slice opaque: the volume's alpha is data (a density, |grad|,
    // a simulation channel), and passing it through as frame alpha made
    // low-alpha volumes disappear once composited.
    isf_FragColor = vec4(textureLod(volume, p, 0.0).rgb, 1.0);
}
