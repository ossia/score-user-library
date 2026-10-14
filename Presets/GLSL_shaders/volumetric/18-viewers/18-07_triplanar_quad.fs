/*{
  "DESCRIPTION": "Triplanar quad: display three orthogonal slices (XY, YZ, ZX) in a 2x2 layout. Plus a small MIP in the corner. Shows the stored (premultiplied) colour opaque, i.e. the volume composited over black; the alpha is not shown.",
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
      "TYPE": "point3d",
      "DEFAULT": [
        0.5,
        0.5,
        0.5
      ],
      "MIN": [
        0,
        0,
        0
      ],
      "MAX": [
        1,
        1,
        1
      ],
      "LABEL": "Slices (x,y,z)"
    }
  ]
}*/

void main()
{
    vec2 uv = isf_FragNormCoord;
    vec2 q = fract(uv * 2.0);
    ivec2 tile = ivec2(floor(uv * 2.0));
    int ti = tile.x + tile.y * 2;     // 0=bl, 1=br, 2=tl, 3=tr
    vec4 col = vec4(0.0);
    if(ti == 0){ col = textureLod(volume, vec3(q.x, q.y, slice.z), 0.0); }
    else if(ti == 1){ col = textureLod(volume, vec3(slice.x, q.x, q.y), 0.0); }
    else if(ti == 2){ col = textureLod(volume, vec3(q.x, slice.y, q.y), 0.0); }
    else {
        vec4 m = vec4(0.0);
        for(int i=0; i<64; i++) m = max(m, textureLod(volume, vec3(q.x, q.y, float(i)/64.0), 0.0));
        col = m;
    }
    // Show the slice opaque: the volume's alpha is data (a density, |grad|,
    // a simulation channel), and passing it through as frame alpha made
    // low-alpha volumes disappear once composited.
    isf_FragColor = vec4(col.rgb, 1.0);
}
