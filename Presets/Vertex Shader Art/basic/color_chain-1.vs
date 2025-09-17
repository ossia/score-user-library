/*{
  "DESCRIPTION": "color chain",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/i2MzwYgwq9p5mJ42Q)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 8196,
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
    "ORIGINAL_VIEWS": 77,
    "ORIGINAL_DATE": {
      "$date": 1544475740223
    }
  }
}*/

void main() {
  gl_PointSize = 5.0;

  v_color = vec4(
    abs(sin(vertexId * 0.1 - time * 8.0)),
    abs(sin(vertexId * 0.1 - time * 8.0 + 2.09)),
    abs(sin(vertexId * 0.1 - time * 8.0 + 4.18879020479)),
    1.0);

  gl_Position.x = sin(time * 2.0 - vertexId / 2.0) * vertexId / 64.0 / 64.0;
  gl_Position.y = cos(time * 2.0 - vertexId / 2.0) * vertexId / 64.0 / 64.0;
  gl_Position.z = 0.0;
  gl_Position[3] = 1.0;
}