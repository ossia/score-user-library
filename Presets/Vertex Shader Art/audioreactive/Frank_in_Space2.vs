/*{
  "DESCRIPTION": "Frank in Space2",
  "CREDIT": "markus (ported from https://www.vertexshaderart.com/art/NeGB5oyRfmeMmWodT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 12200,
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
      "$date": 1599073564827
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xoff = 0.0; // sin(time + y * 0.2) * 0.01;
  float yoff = 0.0; //sin(time * 1.1 + x * 0.3) * 0.02;

  float ux = u * 2.0 - 1.0 + xoff;
  float vy = v * 2.0 - 1.0 + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float su = abs(u - 0.5) * 1.0;
  float sv = abs(v - 0.5) * 2.0;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * 0.05, av * 0.25)).z;

  gl_Position = vec4(xy, 0, 1);

  float soff = snd; // sin(time * 1.2 + x * y * 0.02) * 5.0;

  gl_PointSize = pow(snd + .3, 3.0) * 10.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 1000.0;

  float pump = step(0.1, snd);
  float hue = u * 0.2 + snd + sin(0.9); // sin(time * 1.2 + v * 5.0) * 0.1;
  float sat = mix(0.3, .8, pump);
  float val = mix(0.6, pow(snd + 0.2, 5.0), pump); //sin(time * 1. + v * u * 20.0) + 0.5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.0);
}