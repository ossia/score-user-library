/*{
  "DESCRIPTION": "first test",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ZZPtHWkxTWXKxGiJB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1360,
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
    "ORIGINAL_VIEWS": 58,
    "ORIGINAL_DATE": {
      "$date": 1634513744803
    }
  }
}*/

 void main() {

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  // float pointSize = 5.;

  float x = mod(vertexId, across);
  float y = floor(vertexId /across);

  float u = x/(across-1.);
  float v = y/(across-1.);

  float xoff = sin(time + y * 0.2) * .1;
  float yoff = sin(time + x * 0.3) * .2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy,0,1);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1,0,0,1);

}