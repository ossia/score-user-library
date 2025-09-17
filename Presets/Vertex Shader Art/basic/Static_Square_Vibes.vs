/*{
  "DESCRIPTION": "Static Square Vibes",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/PtvnQNWKfKdFBWHtm)",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1528976791917
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float maxPoints = 10.0;
  float currentCircle = mod(vertexId, maxPoints) * 0.1;
  float norm = vertexId / vertexCount;
  float theta = norm * 6.28;
  float speed = norm * 10.0;

  float vx = cos(theta * time * time) * currentCircle;
  float vy = sin(theta * time) * currentCircle;

  float x = 0.0;
  float y = 0.0;

  x += vx;
  y += vy;

  gl_Position = vec4(x, y, 0.0, 1.0);
  gl_PointSize = norm * 2.0;
  v_color = vec4(1.0, 1.0, 1.0, 1.0);
}