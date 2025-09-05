/*{
  "DESCRIPTION": "2D Circle - Simple 2D Circle Example with min radius. Move ouse to expand the circle",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/DoEj3wxxxKrDkxKrZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1525113056052
    }
  }
}*/

void main() {
  float vertNorm = vertexId / vertexCount;

  float theta = vertNorm * 6.28;
  float amplitude = max(mouse.x, 0.25);
  float posX = cos(theta) * amplitude;
  float posY = sin(theta) * amplitude;

  gl_Position = vec4(posX, posY, 0.0, 1.0);
  gl_PointSize = 5.0;
  v_color = vec4(1.0, 1.0, 1.0, 1.0);
}