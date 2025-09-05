/*{
  "DESCRIPTION": "Audio Reactive - Sangbeom Kim - Audio Reactive - Sangbeom kim",
  "CREDIT": "sangbeom.kim (ported from https://www.vertexshaderart.com/art/xJxsMsamoRikshwtQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 19864,
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
    "ORIGINAL_VIEWS": 10,
    "ORIGINAL_DATE": {
      "$date": 1653420451817
    }
  }
}*/

//CS250 Spring 2022
//Sangbeom Kim
//Exercise - Vertexshaderart : Audio Reactive

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

#define PI radians(180.0)

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

  xy = rotate(time) * xy;

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(av * .04, au * .25)).r;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * .02) * 5.;

  gl_PointSize = pow(snd + 0.2, 10.) * 30.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 1000.;

  float pump = step(0.8, snd);

  float hue = u * .1 + snd * 0.2 + cos(time + snd);
  float sat = mix(0., 1., pump);
  float val = mix(.1, pow(snd + 0.2, 5.), pump);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
