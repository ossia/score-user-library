/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/4zASqsiiCDuSJRntr)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 82287,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.07450980392156863,
    0.06666666666666667,
    0.07058823529411765,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 120,
    "ORIGINAL_DATE": {
      "$date": 1503465544117
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 3.0)
#define STEP 0.10

void main() {
  float point = mod(floor(vertexId /9.0) + mod(vertexId,33.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * 0.1) + 1.0;
  float angle = point * PI * .8 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014,0.8);
  float c = cos(angle + time) * radius;
  float s = sin(angle +time) * sin(radius/ 7.);
  float orbitAngle = pow(count * 0.025, 0.8);
  float innerRadius = pow(count * 0.0005, 1.2);
  float oC = cos(orbitAngle + count * 0.0001) * innerRadius;
  float oS = sin(orbitAngle + count * 0.001) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s );
  gl_Position = vec4(xy -aspect - mouse * 0.1, 0.4, 1);

  float b = 1.0 - pow(sin(count * 0.4) * 0.35 + 0.5, 10.0);
  b = 0.4;mix(0.6, 0.7, b);
  v_color = vec4(0.9, sin(b *time), b/3., 1);
}