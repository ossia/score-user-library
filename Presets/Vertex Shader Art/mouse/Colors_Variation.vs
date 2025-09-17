/*{
  "DESCRIPTION": "Colors Variation",
  "CREDIT": "daehyeon.kim (ported from https://www.vertexshaderart.com/art/6KurZsv36w6xrAoSf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1681,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1652889730133
    }
  }
}*/


vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * .02) * 5.;
  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float hue = time;
  float sat = 1.;
  float val = 1. / (length(vec2(mouse.x, mouse.y) - vec2(ux, vy))) * (sin(time * 10.) * .5 + .5);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
