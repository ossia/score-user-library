/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "ray7551 (ported from https://www.vertexshaderart.com/art/9Sr9XKEznvoJprDjG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 289,
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
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1501331541652
    }
  }
}*/

void main() {
  float gridWidth = floor((vertexCount - floor(sqrt(vertexCount))) / floor(sqrt(vertexCount)));

  gl_PointSize = 10.;
  gl_PointSize *= 20. / gridWidth;
  // gl_PointSize *= resolution.x / 400.;
  vec2 realPointSize = vec2(gl_PointSize) / resolution;

  vec2 p = vec2(
    mod(vertexId, gridWidth),
    floor(vertexId / gridWidth)
  );
  // p = (p / (gridWidth - 1.) ) * 2. - vec2(1., 1.)
  // + vec2(gl_PointSize / resolution / 2.);
  p = (p) / (gridWidth - 1.) * 2.
    - vec2(1., 1.);// + realPointSize;

  gl_Position = vec4(p, 0., 1.);

  v_color = vec4(1. * sin(time), 1., 0.8 * cos(time), 1.);
}