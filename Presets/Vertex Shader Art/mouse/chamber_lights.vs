/*{
  "DESCRIPTION": "chamber lights",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ycNiGDhLy59Wqt9qN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 61924,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.38823529411764707,
    0.28627450980392155,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 67,
    "ORIGINAL_DATE": {
      "$date": 1666078877510
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * 0.01) + 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = pow(count * 0.025, 0.8);
  float innerRadius = pow(count * 0.0005, 1.2);
  float oC = cos(orbitAngle + count * 0.0001) * innerRadius;
  float oS = sin(orbitAngle + count * 0.0001) * innerRadius;
  float ci = cos(0.00001 * 1.0) + tan(0.01 * oC * oS);

  vec2 aspect = vec2(2, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s + ci);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float b = 1.0 - pow(sin(count * 0.4) * 0.5 + 0.5, 10.0);
  b = 0.0;mix(0.0, 0.7, b);
  v_color = vec4(b, b, b, 1);

}