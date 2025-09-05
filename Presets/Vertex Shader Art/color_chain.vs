/*{
  "DESCRIPTION": "color chain - : ^)",
  "CREDIT": "mol (ported from https://www.vertexshaderart.com/art/8YgL5b9rsGLmaeQ9Z)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 14944,
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
    "ORIGINAL_VIEWS": 233,
    "ORIGINAL_DATE": {
      "$date": 1543920559215
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