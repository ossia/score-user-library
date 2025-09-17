/*{
  "DESCRIPTION": "MagnetTV",
  "CREDIT": "freefull (ported from https://www.vertexshaderart.com/art/ZNnRK7kpHZXGz5gT5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 19272,
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
    "ORIGINAL_VIEWS": 1423,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1445840757177
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
#define NUM_LINES_DOWN 64.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.0) + mod(vertexId, 2.0) * STEP;
  // line count
  float count = floor(vertexId / NUM_POINTS);

  float u = point / NUM_SEGMENTS; // 0 <-> 1 across line
  float v = count / NUM_LINES_DOWN; // 0 <-> 1 by line
  float invV = 1.0 - v;

  float x = u * 2.0 - 1.0;
  float y = v * 2.0 - 1.0;
  gl_Position = vec4(x, y, 0, 1);

  gl_PointSize = cos(60.0*(length(vec2(x*sin(y*3.0+time),y))- time/20.0))*4.0 + 4.0;

  float hue = x*y;
  float sat = 0.8;
  float val = 0.8;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}