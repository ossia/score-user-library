/*{
  "DESCRIPTION": "Audio Reactive Art Variation",
  "CREDIT": "minsu-kim-digipen (ported from https://www.vertexshaderart.com/art/jpy7t2fKy3TKStRPG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.0196078431372549,
    0.0196078431372549,
    0.0196078431372549,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1684759010542
    }
  }
}*/

// Name : Minsu Kim
// Assignment : Exercise - Vertexshaderart : Audio Reactive
// Course : CS250
// Spring 2023

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

void main()
{
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float su = abs(u -.5) * 2.;
  float sv = abs(v - .5) * 2.;

  // Angular
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));

  // Sound
  float snd = texture(sound, vec2(au * .05, av * .25)).r;

  gl_Position = vec4(xy, 0, 1);

  float soff = 0.;//sin(time + x * y * 0.02) * 5.;

  gl_PointSize = pow(snd + .2, 5.) * 30.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  // [0, 1)
  float pump = pow(0.1, snd);
  float hue = v * .1 + snd * .2 + time * .1;//sin(time + v * 20.) * 0.05;
  float sat = mix(0.7, 1., pump);//mix(1., -10., 1. - av);
  float val = mix(0.1, 0.2 ,snd + .2 + 5.);//sin(time + v * u * 20.0) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}