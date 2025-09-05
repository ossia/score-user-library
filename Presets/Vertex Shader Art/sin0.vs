/*{
  "DESCRIPTION": "sin0",
  "CREDIT": "pgan (ported from https://www.vertexshaderart.com/art/Pcb2n3yJfxALCGt2x)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3845,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1554729925046
    }
  }
}*/

void main() {
  // gl_PointSize = 10.0;
  gl_PointSize = 5.0;

  float magic = vertexCount;
  vec2 adjust = vec2(-magic / 2.0, -magic / 2.0);

  // float x = mod(vertexId, magic);
  float x = 2.0 * (vertexId / vertexCount) - 1.0;
  // float y = floor(vertexId / magic);
  float y = vertexId / vertexCount;

  float s = sin(mod(vertexId / 100.0, 100.0) - 0.5);

  // gl_Position = vec4(x, y, 0.0, 1.0);
  gl_Position = vec4(x, s, 0.0, 1.0);

  // v_color = vec4(0.0, 1.0, 0.0, 1.0);
  v_color = vec4(s, mod(time * 0.25, 1.0), 0.0, 1.0);
}
