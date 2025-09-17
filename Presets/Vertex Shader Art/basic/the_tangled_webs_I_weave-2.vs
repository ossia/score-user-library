/*{
  "DESCRIPTION": "the tangled webs I weave",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/EbKX65r26sjm5sY7t)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 39,
    "ORIGINAL_DATE": {
      "$date": 1551479888435
    }
  }
}*/

// hash functions

void main() {
  float width = 10.0;

  float x = mod(vertexId, width) * 0.05;
  float y = vertexId * 0.05;

  gl_Position = vec4(x, y, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 20.0;
}
