/*{
  "DESCRIPTION": "snd-scope ",
  "CREDIT": "molotovbliss (ported from https://www.vertexshaderart.com/art/HyBREewYeJJq8kxKa)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 84541,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.11372549019607843,
    0.1450980392156863,
    0.1803921568627451,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 73,
    "ORIGINAL_DATE": {
      "$date": 1658409514219
    }
  }
}*/

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
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

  float snd = texture(sound, vec2(au * 0.01, av * .25)).r;

  float xoff = .1;//sin(time * y) / snd * PI;
  float yoff = .1;//sin(snd * y * PI);

  x = snd / y;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * .01);
  gl_PointSize = pow(snd * time, snd) * snd * soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.0;

  float pump = step(0.01, time);

  float hue = u * .1 + snd * .4 + time / sin(time + v) * .00009 / time;
  float sat = mix(0., 1., pump);
  float val = mix(.1, pow(snd, 20.), pump);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
