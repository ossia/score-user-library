/*{
  "DESCRIPTION": "Lesson03 - Lesson Three tutorial code.",
  "CREDIT": "PLU Collective (ported from https://www.vertexshaderart.com/art/fnQrnopggmFfZmzMG)",
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
    0.08235294117647059,
    0.11372549019607843,
    0.3843137254901961,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1496313951488
    }
  }
}*/

//Lesson 3
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yx, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.x * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

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
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.4;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float hue = u * .1 + sin(time + v * 20.) * 0.05;
  float sat = 1.;
  float val = sin(time + v * u * 20.) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);

}