/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/MgC43FZpWMJiPkiAD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 3,
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
    "ORIGINAL_VIEWS": 56,
    "ORIGINAL_DATE": {
      "$date": 1543837012659
    }
  }
}*/

void main() {
  gl_PointSize = 10.0;
  gl_Position = vec4(0, 0, 0, 1);
  v_color = vec4(1, 0.5, 1, 1);
}