/*{
  "DESCRIPTION": "Learn by Doing",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/vQ7wEjJPEkssSR58B)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1497437991211
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main () {

  float scale = 0.5;
  float tvar1 = 1.;
  float tvar2 = 1.3;

  float timevar1 = (sin(time/tvar1) +1.)/2.;
  float timevar2 = (sin(time/tvar2) +1.)/2.;

  float vc = vertexCount;

  float down = abs(sqrt(vc));
  float across = floor(vc/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);
  float xoff = sin(time+timevar1);
  float yoff = sin(time+timevar2);
  x += xoff;
  y += yoff;

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float su = (u - 0.5) * 2.;
  float sv = (v - 0.5) * 2.;

  vec2 xy = vec2(su, sv);
  xy *= scale;

  gl_Position = vec4(xy, 0, 1);

  gl_PointSize = 10.;
  gl_PointSize *= 20./down;

  float hue = su*timevar1 / sv*timevar2;
  float sat = 1.;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0);

}