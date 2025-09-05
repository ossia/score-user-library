/*{
  "DESCRIPTION": "Juno",
  "CREDIT": "villain (ported from https://www.vertexshaderart.com/art/jH6uYuSxKSryZXLT8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 667,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.043137254901960784,
    0.03137254901960784,
    0.0196078431372549,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 364,
    "ORIGINAL_DATE": {
      "$date": 1562541124382
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 1.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 2.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 2.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 87.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * 4.02;
  float angle = point * PI * 6.0 / NUM_SEGMENTS + offset;
  float radius = 3.5;
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 7.01;
  float oC = cos(orbitAngle + time * count * 0.01) * sin(orbitAngle);
  float oS = sin(orbitAngle + time * count * 0.01) * sin(orbitAngle);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 3);

  float hue = (time * 8.4 + count * 3.);
  v_color = vec4(hsv2rgb(vec3(hue, 6, 4)), 3);
}