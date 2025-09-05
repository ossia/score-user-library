/*{
  "DESCRIPTION": "Audio Reactive Art",
  "CREDIT": "seoseulbin (ported from https://www.vertexshaderart.com/art/nAEy8qdNR79dxXtex)",
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
    0.14901960784313725,
    0.12549019607843137,
    0.33725490196078434,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684840111644
    }
  }
}*/

// Seulbin Seo
// Exercise Audio Reactive Art
// CS250 Spring 2023

vec3 hav2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.x * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.)

void main ()
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

  vec2 xy = vec2(ux, vy)* 1.3;

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(sv, su));
  float snd = texture(sound, vec2(au * .05, av * .25)).r;

  gl_Position = vec4(xy, 0, 1);

  float soff = 0.; //sin(time * 1.2 + x * y * 0.02) * 5.;

  gl_PointSize = pow(snd + 0.2, 5.) * 30. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float pump = step(0.8, snd);
  float hue = u * .1 + snd * 0.2 + time * .1; // + sin(time * 1.3 + v * 20.) * 0.05;
  float sat = mix(0., 1., pump);
  float val =mix(.1, pow(snd + 0.2, 5.), pump); //sin(time * 1.4 + v * u * 20.0) * .5 + .5;

  v_color = vec4 (hav2rgb(vec3(hue, sat, val)), 1);
}

