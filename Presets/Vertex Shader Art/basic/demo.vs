/*{
  "DESCRIPTION": "demo",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/EDJJ9esPSEo3LRLmb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 58181,
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
      "$date": 1556923504176
    }
  }
}*/


#define point_id vertexId
#define point_count vertexCount
#define point_pct (point_id/point_count)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float PI = 3.14;
  float x = 0.5*cos(time + point_pct * 2.0 * PI);
  float y = 0.5*sin(time + point_pct * 2.0 * PI);
  // x -> [-1, 1]
  // y -> [-1, 1]
  // z -> 0
  // w -> [0, inf]
  gl_Position = vec4(x, y, 0.0, 1.0 + 0.2*point_pct);
  gl_PointSize = 20.0 * point_pct;
  float hue = point_pct;
  float sat = 1.0;
  float val = 1.0;
  v_color = vec4(hsv2rgb(vec3(hue + 1.0 * time, sat, val)), 1);
}