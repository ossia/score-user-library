/*{
  "DESCRIPTION": "starter",
  "CREDIT": "mike-tobia (ported from https://www.vertexshaderart.com/art/Cou2fm28Bk2J2vbgy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Nature",
    "Abstract"
  ],
  "POINT_COUNT": 1500,
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
      "$date": 1555796005956
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

  float xoff = sin(time + y * .2) * .2;
  float yoff = sin(time + x * .2) * .2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float scale = .1;

  vec2 xy = vec2(ux, vy) * scale;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * .002) * 15.;

  gl_PointSize = 10. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= mod(resolution.x / 600. * scale, 1.);

  v_color = vec4(1, 1, 1, 1);
}