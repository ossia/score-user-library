/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ur9ypANXXdW8q9gmW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1,
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
    "ORIGINAL_VIEWS": 67,
    "ORIGINAL_DATE": {
      "$date": 1551479168664
    }
  }
}*/

void main()
{
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 20.0;
}