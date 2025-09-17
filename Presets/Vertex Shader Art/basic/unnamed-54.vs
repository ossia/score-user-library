/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/EFCx8Coh8CuLXJXue)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 2,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 35,
    "ORIGINAL_DATE": {
      "$date": 1551479683781
    }
  }
}*/

void main()
{
  float x = vertexId * 0.1;
  gl_Position = vec4(x, 0.0, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 20.0;
}

