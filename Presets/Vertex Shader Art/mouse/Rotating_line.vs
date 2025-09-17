/*{
  "DESCRIPTION": "Rotating line",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/LvJLKq69EEcAHDcJh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1831,
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
    "ORIGINAL_VIEWS": 88,
    "ORIGINAL_DATE": {
      "$date": 1593816178433
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 circleCoord(float angle, float rad) {
  return vec2(cos(radians(angle)) * rad, sin(radians(angle)) * rad);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
/* float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2;
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.01;
  float oC = cos(orbitAngle + time * count * 0.01) * sin(orbitAngle);
  float oS = sin(orbitAngle + time * count * 0.01) * sin(orbitAngle);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);*/
  // gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);
  // gl_Position = vec4(-1, sin(time), 0, 1);
// gl_Position = vec4(circleCoord(vertexId * 4.0, 0.2 * time * 0.005), 0.9, 1);
  vec2 actual_coord = vec2(-1.0 + (vertexId / 1000.0), 0);
  gl_Position = vec4(circleCoord(time*50., -1. + (vertexId) / 1000.), 0, 1);

  float hue = (time * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
  gl_PointSize = 5.0;
}