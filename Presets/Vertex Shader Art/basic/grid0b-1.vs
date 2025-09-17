/*{
  "DESCRIPTION": "grid0b",
  "CREDIT": "pgan (ported from https://www.vertexshaderart.com/art/89PHWvc6bSoMDB4uq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 50,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1554728196457
    }
  }
}*/

void main() {
  // gl_PointSize = 10.0;
  gl_PointSize = 5.0;

  float magic = vertexCount;
  vec2 adjust = vec2(-magic / 2.0, -magic / 2.0);

  // float x = mod(vertexId, magic);
  float x = 2.0 * (vertexId / vertexCount) - 1.0;
  // float y = floor(vertexId / magic);
  float y = vertexId / vertexCount;

  gl_Position = vec4(x, y, 0.0, 1.0);

  v_color = vec4(0.0, 1.0, 0.0, 1.0);
}
