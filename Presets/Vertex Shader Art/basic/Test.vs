/*{
  "DESCRIPTION": "Test",
  "CREDIT": "sairu312 (ported from https://www.vertexshaderart.com/art/JZfSq6roYfXYSQTYs)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 4875,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1576673874005
    }
  }
}*/


//#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
//#define STEP 1.0

void main() {
  vec3 p;

  //triangleIdは三角形の識別ようID
  //triangleVertexIdはその三角形内での頂点の識別IDは
  float triangleId = floor(vertexId / 3.0);
  float triangleVertexId = mod(vertexId, 3.0);

  float angle = radians(60.0) * (triangleVertexId * 2.0 + triangleId * 0.6667);
  p = vec3(sin(angle), cos(angle), -0.01 * triangleId);

  p.x *= resolution.y / resolution.x;

  gl_Position = vec4(p * 0.8, 1);
  gl_PointSize = 10.0;

  v_color = vec4(0.5, 0.5, 0.5, 0.5);
}