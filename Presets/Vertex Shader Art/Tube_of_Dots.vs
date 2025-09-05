/*{
  "DESCRIPTION": "Tube of Dots",
  "CREDIT": "nathan2 (ported from https://www.vertexshaderart.com/art/DRYszuLsxNkzcz9SW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16743,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.0784313725490196,
    0.058823529411764705,
    0.027450980392156862,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1574455156182
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

  // Calculate angle and radial values
  float angle = ux / numSegments * 2.0 * PI;
  float c = cos(angle);
  float s = sin(angle);

  // Translate back to x y
  float radius = vy;
  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

void main() {
  float numSegments = 20.0;
  float numPointsPerCircle = numSegments * 6.0;

  float numCircles = floor(vertexCount / numPointsPerCircle) - 1.0;
  float circleId = floor(vertexId / numPointsPerCircle);

  vec2 xy = getCirclePoint(vertexId, numSegments) * 0.1;

  float cX = 2.0 * (circleId / numCircles) - 1.0;

  float nearness = abs(cos((time + circleId) / 2.0));

  gl_Position = vec4(xy.x + cX, xy.y + sin(time + circleId)*0.5, 0.0, 1);
  gl_PointSize = 2.0 * nearness + 1.0;

  // Circle color
  float hue = sin(circleId * 0.1 + time * .1) * 0.8;
  float sat = 0.4;
  float val = 1.0;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.0);

}