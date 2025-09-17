/*{
  "DESCRIPTION": "the tangled webs I weave",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/a4rkLdCiX5RnyGq6x)",
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
    "ORIGINAL_VIEWS": 57,
    "ORIGINAL_DATE": {
      "$date": 1551479698360
    }
  }
}*/

// hash functions

void main() {
  float x = vertexId * 0.1;

  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 20.0;
}
