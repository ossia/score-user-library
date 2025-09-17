/*{
  "DESCRIPTION": "color own variation",
  "CREDIT": "byungchan.park (ported from https://www.vertexshaderart.com/art/9LoJ64iLFmQukm5ha)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 69139,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.027450980392156862,
    0.027450980392156862,
    0.19215686274509805,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1684489761643
    }
  }
}*/

//name : Byungchan Park
//assignment : Exercise - Vertexshaderart : color own variation
//course name : CS250
//term : Spring 2023

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = (x*y) / (across - 1.);
  float v = (x*y) / (across - 1.);

  float xoff = sin(time + x + y ) * 0.3 ;
  float yoff = 0.1;

  float ux = xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux,vy) * 1.3;

  gl_Position = vec4(xy,0,1);

  float soff = sin(time * 1.2 + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 100.;

  float hue = u * .1 + sin(time * 1.3 + v * 20.) * 0.05;
  float sat = 1.;
  float val = sin(time * 1.4 + v * u * 20.) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}