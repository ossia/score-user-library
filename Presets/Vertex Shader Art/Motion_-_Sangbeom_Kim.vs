/*{
  "DESCRIPTION": "Motion - Sangbeom Kim - Motion - Sangbeom Kim",
  "CREDIT": "sangbeom.kim (ported from https://www.vertexshaderart.com/art/qof5bDEpQyu2B6HFC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16132,
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
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1652868099690
    }
  }
}*/

//CS250 Spring 2022
//Sangbeom Kim
//Exercise - Vertexshaderart : Motion Assignment

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time * 10. + y * 0.3) * 0.1;
  float yoff = sin(time + x * 0.2) * 0.1;

  float ux = u * 2. -1. + xoff;
  float vy = v * 2. -1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 * (sin(time * 3.) + 2.) + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(u, v, 1. - u - v, 1);

}