/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "tomjakubowski (ported from https://www.vertexshaderart.com/art/ioLq6J2WDmNXguCmD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 8000,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1567579359194
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

float line(float id, float count) {
  // x: 0.0 0.0 1/n 1/n 2/n 2/n 3/n 3/n .. n/n n/n
  float x = id / (count - 1.0);
  return x;
}

void main() {
  float t = vertexId/vertexCount;
  float x = line(vertexId, vertexCount);
  float y = sin(2.0*PI*x);
  gl_Position = vec4(2.0*x-1.0, y, 0.0, 1.0);
  gl_PointSize = 2.0;
  v_color = 0.5 * vec4(hsv2rgb(vec3(t+time, 0.5, 0.6)), 1.0);
}