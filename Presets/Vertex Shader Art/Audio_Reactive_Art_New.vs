/*{
  "DESCRIPTION": "Audio Reactive Art New",
  "CREDIT": "hyosang_jung (ported from https://www.vertexshaderart.com/art/BtMPmXiuE37mpnQB7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1653482023088
    }
  }
}*/

//Name: Hyosang Jung
//Assignment Name: Exercise - Vertexshaderart : Audio Reactive
//Course Name: CS250
//Term&Year: 2022&Fall
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;

  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));

  float snd = texture(sound, vec2(0, av)).r;

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  vec2 xy = vec2(ux, vy);

  gl_Position = vec4(ux,vy, 0, 1);

  float soff = 1.;//sin(time + x * y * .02) * 5.;
  gl_PointSize = pow(snd, 5.0) * 30.0*(abs(sin(time))+0.5) + soff;

  float pump = step(0.8, snd);

  float hue = u * .1 + snd * 0.2 + time * .1; //sin(time + v * 20.) * .05;
  float sat = mix(0., 1., pump);
  float val = mix(.1, pow(snd + 0.2, 5.0), pump);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}