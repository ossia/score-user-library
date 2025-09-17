/*{
  "DESCRIPTION": "Audio Reactive - Geumbi Yeo",
  "CREDIT": "geumbi.yeo (ported from https://www.vertexshaderart.com/art/Ri8Y9A63oZsG2BkYf)",
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1684769664606
    }
  }
}*/

// Name : Geumbi Yeo
// Assignment : Audio Reactive - Geumbi Yeo
// Course : CS250
// Term & Year : Spring 2023

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
  float PI = 3.1415926535;
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

  float su = (u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / (PI / 2.);
  float av = length(vec2(sv, su));
  float snd = texture(sound, vec2(av * .1, au * .3)).r * 1.2;

  gl_Position = vec4(xy, 0, 1);

  float soff = 3.; //sin(time + x * y * 0.02) * 5.;

  gl_PointSize = pow(snd + 0.2, 5.) * 30.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float pump = step(0.85, snd);
  float hue = u * .1 + snd * 0.2 + time * .1 * cos(time * 2.); //sin(time + v * 20.) * 0.05;
  float sat = mix(0., 1., pump * abs(sin(time * 4.))); //mix(1., -10., av);
  float val = mix(.1, pow(snd + 0.2, 5.), pump); //sin(time + v * u * 20.0) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}