/*{
  "DESCRIPTION": "lesson 2",
  "CREDIT": "tjak (ported from https://www.vertexshaderart.com/art/i45xFrKEbpDpjYMW8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
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
      "$date": 1558920065976
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

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;
  gl_Position = vec4(xy, 0., 1.);

  float szoff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 + szoff;
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1., 0., 0., 1.);
}