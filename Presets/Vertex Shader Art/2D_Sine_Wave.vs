/*{
  "DESCRIPTION": "2D Sine Wave",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/rfN5XjXn3a69T3A7z)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Effects"
  ],
  "POINT_COUNT": 1000,
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
      "$date": 1530865402306
    }
  }
}*/

// 2D Sin Wave

void main() {
  float vertexNorm = vertexId/vertexCount;
  float x = vertexNorm - 0.5;
  float y = 0.25 * sin(time + vertexNorm * 2.0);

  gl_Position = vec4(x, y, 0.0, 1.0);
  gl_PointSize = vertexNorm * 10.0;
  v_color = vec4(vertexNorm, 0.0, x, 1.0);
}