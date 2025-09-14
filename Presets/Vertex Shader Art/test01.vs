/*{
  "DESCRIPTION": "test01 - Test project",
  "CREDIT": "danielskantze (ported from https://www.vertexshaderart.com/art/wm8Y738CbMGQQkW63)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1683742228826
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float p = vertexId / vertexCount;
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  float size = min(resolution.x, resolution.y);
  float inset = 0.8;

  float laps = 10.0;

  vec2 pos = vec2(inset * sin(laps * PI * p * 2.0), inset * cos(laps * PI * p * 2.0));

  pos = pos * aspect;
  // gl_Position = vec4(pos * aspect + mouse * 0.1, 0, 1);
  gl_Position = vec4(pos.x, p, pos.y, 1);

  float hue = (time * 0.01 + p * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}