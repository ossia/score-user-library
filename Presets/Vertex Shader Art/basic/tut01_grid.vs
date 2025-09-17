/*{
  "DESCRIPTION": "tut01_grid",
  "CREDIT": "sherrysmcguire (ported from https://www.vertexshaderart.com/art/S69GThF6s72FaScEz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
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
      "$date": 1687641281615
    }
  }
}*/

void main() {

  gl_Position = vec4(0, 0, 0, 1);
  gl_PointSize = 10.0;
  v_color = vec4(1, 0, 0, 1);

}