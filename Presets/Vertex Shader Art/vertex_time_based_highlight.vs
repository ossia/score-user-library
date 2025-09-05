/*{
  "DESCRIPTION": "vertex+time based highlight",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/QfDybr9wdsTip3KZ5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 103,
    "ORIGINAL_DATE": {
      "$date": 1487642745739
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 500.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(0, vertexId * aspect.x / 500. - 1., 0, 1);

  vec4 color = vec4(0.5, 0.25, 0.5, 1);
  vec4 highlight = vec4(1, 1, 1, 0.5);
  float length_of_sword = 1000.; // in vertices
  float time_speed = 2000.; // arbitrary
  highlight *= mod(vertexId - time * time_speed, length_of_sword) / length_of_sword;
  v_color = color + highlight;
}