/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/XYGETLizFzAGcWS7N)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 17,
    "ORIGINAL_DATE": {
      "$date": 1699314176533
    }
  }
}*/

void main()
{
  v_color = vec4(0.0, 0.0, 0.0, 1.0);
  gl_PointSize = 20.0;

  vec2 xy = vec2(0.0, 0.0);
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
}