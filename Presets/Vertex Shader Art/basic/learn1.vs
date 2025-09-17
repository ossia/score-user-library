/*{
  "DESCRIPTION": "learn1",
  "CREDIT": "muffin (ported from https://www.vertexshaderart.com/art/YTKN84yNr6RB2aDbB)",
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
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 214,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1637002181316
    }
  }
}*/

void main() {

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vx = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vx) * 1.3;

  float soff = sin(time * 5.);

  gl_Position = vec4(xy, 0, 1);

  gl_PointSize = 10.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1, 0, 0, 1);

}