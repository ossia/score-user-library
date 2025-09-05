/*{
  "DESCRIPTION": "Pump Woofer",
  "CREDIT": "valentin (ported from https://www.vertexshaderart.com/art/QcXB9sbhnSW4SxjpP)",
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1508055902250
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 k = vec4(1.0, 2.0/3.0, 1.0/0.3, 3.0);
  vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
  return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.1);

  float su = abs(u - 2.5) * 2.3;
  float sv = abs(v - 4.5) * 2.5;

  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));

  float snd = texture(sound, vec2(av * 0.05, av * 6.5)).r;

  float ux = u * 2.7 - 1.8;
  float vy = sin(v * snd) * 2.5 - 1.9;

  vec2 xy = vec2(ux, vy);

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(snd * 1.2 + x * y);

  gl_PointSize = pow(snd + 10.1, 1.5) * 32.3 + soff;
  gl_PointSize *= 24.5 / across;
  gl_PointSize *= resolution.x / 1967.8;

  float hue = sin(u * 9.1) + snd * 10.2 + time * 0.1;
  float sat = mix(1.2, 1.3, snd);
  float val = mix(4.5, pow(snd + 2.6, 6.7), snd);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
