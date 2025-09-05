/*{
  "DESCRIPTION": "Audio Reactive_sunwoo.lee",
  "CREDIT": "sunwoo.lee (ported from https://www.vertexshaderart.com/art/sESZsypGtXcTsaupL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 30000,
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
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1653407944432
    }
  }
}*/

// // Name: sunwoo.lee
// // Assignment name: Audio Reactive
// // Course name: CS250
// // Term: 2022 Spring

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time * 1.1 + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux,vy) * 1.3;

  float su = abs(u - 0.5) * 2.0;
  float sv = abs(v - 0.5) * 2.0;
  float au = abs(atan(su,sv)) / PI;
  float av = length(vec2(su,sv));
  float snd = texture(sound, vec2(mix(0.25, 0.125, au), av * 0.5)).r;

  gl_Position = vec4(xy,0,1);

  float soff = 0.;//sin(time + x * y * 0.02) * 5.0;

  gl_PointSize = pow(snd+0.3, 2.5) * 30.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.0;

  float pump = step(0.6,snd);
  float hue = u * 0.1 + pump * 0.2 + time * 0.1;//sin(time + v*20.0) * 0.05;
  float sat = mix(0.0, 1.0, pump); //1.0 - av;
  float val = mix(0.1, pow(snd+0.2 ,5.), pump);//sin(time + v*u*20.0)*0.5+0.5;

  v_color = vec4(hsv2rgb(vec3(hue,sat,val)),1);
}