/*{
  "DESCRIPTION": "Dots",
  "CREDIT": "danieljcage (ported from https://www.vertexshaderart.com/art/5Yw6GiojcPykGM7p6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5294,
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
    "ORIGINAL_VIEWS": 237,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1694130564773
    }
  }
}*/

void main() {
  float down = floor(sqrt (vertexCount));
  float across = floor(vertexCount / down);
  float x = mod (vertexId, across);

  float y = floor(vertexId / across);

  float u = x/(across - 1.);
  float v = y/ (across - 1.);

  // Offsets
  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.2) * 5.3;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  // Scale
  vec2 xy = vec2(ux, vy) * .5;

  gl_Position = vec4(xy, 0, 1.);

  // Off size
  float soff = sin(time) * 5.;

  gl_PointSize = 10.0 + soff;
  gl_PointSize = 20. / across;
  gl_PointSize = resolution.x / 600.;
  v_color = vec4(.1, 0.5, 1, 1);
}