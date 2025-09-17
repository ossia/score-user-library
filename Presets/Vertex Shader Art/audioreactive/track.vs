/*{
  "DESCRIPTION": "track",
  "CREDIT": "mike-tobia (ported from https://www.vertexshaderart.com/art/pdHu6xfHPYi6Yznt5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1555808030778
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
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float snd = texture(sound, vec2(u, v)).r;

  float xoff = 0.; // sin(time + y * .2) * .1;
  float yoff = 0.; // sin(time + x * .3) * .1;
  float zoff = 0.; // sin(time + 1. * .3) * .1;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float scalar = 1.3;
  float scale = scalar;

  vec2 xy = vec2(ux, vy) * scale;
  float z = 1. * mod(scale * zoff, 1.);

  gl_Position = vec4(xy, z, 1.);

  float soff = sin(time + xy.x * xy.y * .002);

  gl_PointSize = 150. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float hue = 1.29;
  float sat = 1.;
  float val = snd;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}