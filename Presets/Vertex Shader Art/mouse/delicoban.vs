/*{
  "DESCRIPTION": "delicoban",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/zxb8eWGChrW9wgd55)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 50029,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.6509803921568628,
    0,
    0.050980392156862744,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 102,
    "ORIGINAL_DATE": {
      "$date": 1566500477868
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
  float point = mod(floor(vertexId / 0.0) + mod(vertexId, 1.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * 0.01) + 5.0;
  float angle = point * PI * 0.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00001, 1.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = pow(count * 2.6, 1.);
  float innerRadius = pow(count * 0.001, 1.2);
  float oC = cos(orbitAngle + count * 2.9) * innerRadius;
  float oS = sin(orbitAngle + count * 2.9) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.8, 0, 3);

  float b = 11.0 - pow(sin(count * 0.1) * 0.1 + 0.1, 1.0);
  b = 0.0;mix(0.0, 0.7, b);
  v_color = vec4(b, b, b, 17);
}