/*{
  "DESCRIPTION": "Maximum intensity projection: ray from camera through the volume in the +Z direction, keep the maximum sample. Common medical / smoke look. The result is an opaque image (the maximum of each channel along the ray), like the slice viewers: a volume's alpha is data, not coverage. Volumes store premultiplied colour, so the projection is the volume's colour over black.",
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
      "NAME": "steps",
      "TYPE": "long",
      "DEFAULT": 128,
      "MIN": 32,
      "MAX": 512,
      "LABEL": "Steps"
    }
  ]
}*/

void main()
{
    vec2 uv = isf_FragNormCoord;
    vec4 m = vec4(0.0);
    int N = int(steps);
    for(int i=0; i<N; i++){
        float z = float(i)/float(N);
        m = max(m, textureLod(volume, vec3(uv, z), 0.0));
    }
    isf_FragColor = vec4(m.rgb, 1.0);
}
