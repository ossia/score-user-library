/*{
  "DESCRIPTION": "Dots",
  "CREDIT": "nathan2 (ported from https://www.vertexshaderart.com/art/ZTEp3znDaGd9mFj4J)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1320,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.043137254901960784,
    0.07058823529411765,
    0.09019607843137255,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1574377652016
    }
  }
}*/

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 getCirclePoint(float id, float numSegments) {
  // Each square is made of 2 triangles, 6 points
  float ux = mod(id, 2.0) + floor(id / 6.0);
  float vy = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);

  //
  float angle = ux / numSegments * 2.0 * PI;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy;

  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

void main() {
  float numSegments = 20.0;
  float numPointsPerCircle = numSegments * 6.0;

  float circleId = floor(vertexId / numPointsPerCircle);

  vec2 xy = getCirclePoint(vertexId, numSegments) * 0.1;

  gl_Position = vec4(xy.x + circleId * 0.1 - 0.5, xy.y + sin(time + circleId)*0.1, 0, 1);

  // Circle color
  float hue = sin(circleId * 0.1 + time * .1) * 0.8;
  float sat = 0.4;
  float val = 1.0;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0.5);
}