/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/gyyeCLrtNBFwdqzD3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 71,
    "ORIGINAL_DATE": {
      "$date": 1543838598710
    }
  }
}*/

void main() {
  gl_PointSize = 10.0;

  vec2 xy = vec2(vertexId / 3.0, vertexId / 3.0);

  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);

  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}