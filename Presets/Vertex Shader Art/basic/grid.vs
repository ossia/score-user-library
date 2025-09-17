/*{
  "DESCRIPTION": "grid",
  "CREDIT": "iguacel (ported from https://www.vertexshaderart.com/art/8JCNkReuE5hLqBoNT)",
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
    0.07058823529411765,
    0.11372549019607843,
    0.32941176470588235,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1672697141713
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
  float yoff = sin(time + x * 0.3) * 0.1;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float scale = .9;
  vec2 xy = vec2(ux, vy) * scale;

  gl_Position = vec4(xy, 0., 1.);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(0., 1., 0., 1.);
}