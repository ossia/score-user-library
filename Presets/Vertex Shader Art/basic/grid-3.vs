/*{
  "DESCRIPTION": "grid",
  "CREDIT": "iguacel (ported from https://www.vertexshaderart.com/art/JwXL4sBud9x3F6iKY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 13199,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.07058823529411765,
    0.11372549019607843,
    0.32941176470588235,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1672691182552
    }
  }
}*/

void main() {

  float down = floor(sqrt(vertexCount));

  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float xoff = sin(time + y * 0.1) * 0.1;
  float yoff = sin(time + x * 0.1) * 0.1;
  float soff = sin(time + x) * -0.2 * 10.;

  float u = x / (across - 1.) + xoff;
  float v = y / (across - 1.) + yoff;

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float scale = 0.9;
  vec2 xy = vec2(ux, vy) * scale;

  gl_Position = vec4(xy, 0., 1.);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600. * soff;

  v_color = vec4(0., 1., 0., 1.);
}