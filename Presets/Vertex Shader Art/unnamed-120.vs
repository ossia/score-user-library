/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/aKTdaStpa8ugaemPs)",
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
    "ORIGINAL_VIEWS": 21,
    "ORIGINAL_DATE": {
      "$date": 1543837072706
    }
  }
}*/

void main() {
  gl_PointSize = 10.0;
  gl_Position = vec4(0, 0, 0, 1);
  v_color = vec4(1, 0, 0, 1);
}