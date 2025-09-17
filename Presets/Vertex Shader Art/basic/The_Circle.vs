/*{
  "DESCRIPTION": "\"The Circle\"",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/R4ridvuayrATd6Tgy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.17647058823529413,
    0.17647058823529413,
    0.17647058823529413,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 168,
    "ORIGINAL_DATE": {
      "$date": 1540721139387
    }
  }
}*/

mat2 Rotate2D (float x) {
  float a = sin(x), b = cos(x);
  return mat2(b, -a, a, b);
}

void main () {
  vec2 pos = vec2(vertexId/vertexCount, abs(sin(time)))*0.8 * Rotate2D(vertexId+time*10.0);
  gl_PointSize = 15.0;
  gl_Position = vec4(pos, 0.0, 1.0);
  v_color = vec4(pos.x, pos.y, -pos.x, 1.0) + 0.5;
}