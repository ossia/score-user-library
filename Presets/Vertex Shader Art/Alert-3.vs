/*{
  "DESCRIPTION": "Alert - aka Re_gain",
  "CREDIT": "daff (ported from https://www.vertexshaderart.com/art/jBYxLqMCJXqt6uG5C)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
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
      "$date": 1544401121300
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x,clamp(c.yz, 0.0, 1.0));
  vec4 k= vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p= abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
  return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

void main() {

  #define PI radians(180.0)
  //jkj
  //

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;//sin(time * 1.1 + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2 (au * .05, av * .25)).r;//texture(sound, vec2 (su * .05, sv * .25)).r;//texture(sound, vec2 (u * 0.125, v)).r;//texture(sound, vec2 (u, v * 0.125)).r;//texture(sound, vec2 (u, v)).r;

  gl_Position = vec4(xy, 0, 1);

  float soff = 0.;//sin(time + x *y * 0.02) * 5.;// sin(time * 1.2 + x *y * 0.02) * 5.;

  gl_PointSize = pow(snd + 0.2, 5.)* 30.0 + soff;//snd * 30.0 + soff;//15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float pump = step(0.8, snd);
  float hue = u * .1 + snd * 0.2 + time * .1;//u * .1 + sin(time + v * 20.) * 0.05;//u * .1 + sin(time * 1.3 + v * 20.) * 0.05; //u;
  float sat = mix(0., 1., pump);//mix(1., -10., av);//1.;
  float val = mix(.1, pow(snd + 0.2, 5.), pump);//pow(snd + 0.2, 5.);//sound;//sin(time + v * u * 20.0) * .5 + .5;//sin(time * 1.4 + v * u * 20.0) * .5 + .5;//v;

  v_color = vec4(hsv2rgb(vec3(hue, sat , val)), 1);//vec4(1,u,v,1);
}