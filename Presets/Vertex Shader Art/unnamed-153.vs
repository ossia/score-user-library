/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/jtB7xCrYixyTqmxB8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 76979,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.48627450980392156,
    0.38823529411764707,
    0.047058823529411764,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1498816980870
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 3.0

void main() {
  float point = mod(floor(vertexId / 4.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count - sin(time * 0.1) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);
  float c = cos(angle * time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = pow(count * 0.025, 1.08);
  float innerRadius = pow(count * 0.005, 1.2);
  float oC = cos(orbitAngle * count * 0.0001) * innerRadius;
  float oS = sin(orbitAngle + count * 0.01) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC - c*2.,
      oS + s);
  gl_Position = vec4(xy / aspect + mouse * -0.1, -1, 1);

  float b = 1.0 - pow(sin(count * 4.4) * 10.5 - 0.5, 10.0);
  b = 0.0;mix(0.0, sin(1.7), 8.);
  v_color = vec4(b, c, b, 1);
}