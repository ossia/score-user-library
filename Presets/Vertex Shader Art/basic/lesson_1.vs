/*{
  "DESCRIPTION": "lesson 1",
  "CREDIT": "tjak (ported from https://www.vertexshaderart.com/art/KpZcShvoy64nZQwG7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.13725490196078433,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1558919614496
    }
  }
}*/

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);
  // 0 1 2 3 4 5 ... 10 11 12 13 ... 80 81 82 83 ...
  vertexId;
  // 0 1 2 3 4 5 ... 0 1 2 3 ... 0 1 2 3 ...
  float x = mod(vertexId, across);
  // 0 0 0 0 0 0 ... 1 1 1 1 ... 8 8 8 8 ...
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;
  gl_Position = vec4(ux, vy, 0., 1.);
  gl_PointSize = 10.0;
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1., 0., 0., 1.);
}