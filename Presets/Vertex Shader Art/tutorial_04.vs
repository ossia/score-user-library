/*{
  "DESCRIPTION": "tutorial_04",
  "CREDIT": "kcha (ported from https://www.vertexshaderart.com/art/d5q4WZfHWEwTikN2o)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1533,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0.14901960784313725,
    0.3764705882352941,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1551870065980
    }
  }
}*/

vec3 hsv2rgb(vec3 c){
  c = vec3(c.x, clamp(c.yz, 0., 1.));
  vec4 K = vec4(1., 2. / 3., 1. / 3., 3.);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6. - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0., 1.), c.y);
}

#define PI radians(180.0)

void main(){
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across); // 0, 1, 2, ..., 9, 0, 1, ...
  float y = floor(vertexId / across); // 0,0,...0, 1,1,1

  // 0.0 - 1.0
  float u = x / (across - 1.); // .0, .1, ... , .9, .0, .1, ...
  float v = y / (across - 1.); // .0, .0, ... , .1, .1, ...

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  // 0.0-1.0 => -0.5-0.5 => 0.5-0.0-0.5 => 1.0-0.0-1.0
  float su = abs(u - .5) * 2.;
  float sv = abs(v - .5) * 2.;

  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * .05, av * .25)).r;

  gl_Position = vec4(xy, 0, 1);

  float soff = 0.; //sin(time + x * y * 0.02) * 5.;

  gl_PointSize = pow(snd + .2, 5.) * 30. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float pump = step(0.8, snd);
  float hue = u * .1 + snd * .2 + time * .2;//sin(time + v * 20.) * .05;
  float sat = mix(0.0, 1.0, pump);//mix(1., 0., av);
  float val = mix(.1, pow(snd + .2, 5.), pump);//sin(time + v * u * 20.0) * .5 + .5;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  2 + 3;
}
