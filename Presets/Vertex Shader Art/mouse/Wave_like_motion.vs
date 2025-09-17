/*{
  "DESCRIPTION": "Wave like motion - This stuff is super radical",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/qSJ4doZdZD5GW3Y5g)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1524505967775
    }
  }
}*/

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float mouseX = max(mouse.x, -.5);
  mouseX = min(mouseX, 0.5);

  float xOffset = sin(time + y * 0.2) * mouseX * 0.2;
  float yOffset = sin(time + x * 0.3) * 0.1;

  float dx = u * 2.0 - 1.0 + xOffset;
  float dy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2(dx, dy) * 0.75;

  gl_Position = vec4(xy, 0.0, 1.0);

  gl_PointSize = 200.0 / across;
  gl_PointSize *= resolution.x / 600.0 * vertexId / vertexCount;

  v_color = vec4(vertexId / vertexCount, 0.0, abs(cos(time)), 1);
}