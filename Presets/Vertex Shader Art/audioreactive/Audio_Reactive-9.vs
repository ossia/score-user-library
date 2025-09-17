/*{
  "DESCRIPTION": "Audio Reactive",
  "CREDIT": "yejin-shin (ported from https://www.vertexshaderart.com/art/tTpdRDPwymLa9i5Mo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16384,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1684934028157
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float PI = 3.141592;

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.; //sin(time + y * 0.2) * 0.1;
  float yoff = 0.; //sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float su = abs(u - 0.5) * 0.87;
  float sv = abs(v - 0.5) * 0.87;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * 0.06, av * 0.28)).r;

  gl_Position = vec4(xy, 0, 1);

  gl_PointSize = pow(snd + 0.2, 5.) * 50.0;
  gl_PointSize *= 10. / across;
  gl_PointSize *= resolution.x / 350.;

  float pump = step(0.8, snd);
  float hue = u * .1 + snd * 0.2 + time * .1;
  float sat = mix(0., 1., pump);
  float val = mix(.1, pow(snd + 0.2, 5.), pump);

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}