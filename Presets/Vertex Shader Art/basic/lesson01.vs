/*{
  "DESCRIPTION": "lesson01",
  "CREDIT": "leonzh2k (ported from https://www.vertexshaderart.com/art/h3FP6QYiZoQbwACiy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 16384,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1670908615741
    }
  }
}*/

void main() {

  gl_Position = vec4(0, 0, 0, 1);
  gl_PointSize = 10.0;
  v_color = vec4(1, 0, 0, 1);
}