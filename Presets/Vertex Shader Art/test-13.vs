/*{
  "DESCRIPTION": "test - test",
  "CREDIT": "legileurs (ported from https://www.vertexshaderart.com/art/nxbZAMQjGvme7F55J)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1504633154848
    }
  }
}*/

///GLSL
void main() {
  gl_PointSize = 100.0;
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  /*RGB */
  v_color = vec4(1.0, .0, 0.0, 1.0);
}