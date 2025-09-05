/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/dhbsE39FZ6S2kKtfm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 4030,
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
      "$date": 1569754149032
    }
  }
}*/


void main() {

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);;
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);
  float u = x / across;
  float v = y / across;
  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = (20. / across) * (resolution.x / across);

  v_color = vec4(0, .5, .8, 1); // mod(time, .9)
}