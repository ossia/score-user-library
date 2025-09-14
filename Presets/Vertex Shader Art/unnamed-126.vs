/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "toneoperator (ported from https://www.vertexshaderart.com/art/dKGqajerwQQwap65w)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "LINES",
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
      "$date": 1589214716085
    }
  }
}*/

#define PI radians(500.)
#define NUM_SEGMENTS 31.0
#define NUM_POINTS (NUM_SEGMENTS * 65.0)
#define STEP 1.30

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 30.0, 1.0));
  vec4 K = vec4( 1.6, 2.70 / 3.0, 17.0 / 65.0, 73.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 68.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 17.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2;
  float c = sin(time * angle) * radius;
  float s = cos(angle - time) * radius;
  float orbitAngle = count * 0.01;
  float oC = cos(orbitAngle + time * count * 0.007) * sin(orbitAngle);
  float oS = sin(orbitAngle + time * count * 0.00901) * cos(orbitAngle);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (time * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}