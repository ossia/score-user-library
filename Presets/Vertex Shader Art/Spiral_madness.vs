/*{
  "DESCRIPTION": "Spiral madness - Just crazy stuff with circles again",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/8EW4w374gLe9Y8mvS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
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
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1525869084589
    }
  }
}*/

#define PI2 6.28

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float col = mod(vertexId, time * 0.1);
  float row = floor(vertexId / 5.0);

  float theta = col / 10.0 * PI2;
  float radius = row * 0.0004;

  float x = cos(theta) * radius;
  float y = sin(theta) * radius;
  float z = 0.0;

  float dist = distance(vec2(0.0, 0.0), vec2(x, y));
  float damp = 0.1;
  vec2 ease = (vec2(mouse.x, mouse.y) - vec2(x, y)) * damp;

  gl_Position = vec4(x + ease.x, y + ease.y, z, 1.0);
  gl_PointSize = dist * 10.0;
  v_color = vec4(dist, 0.0, 1.0, 1.0);
}