/*{
  "DESCRIPTION": "quad test",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/2pccx6pQfk6skHLQG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 6,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 71,
    "ORIGINAL_DATE": {
      "$date": 1533038728181
    }
  }
}*/

void main() {

  if (vertexId == 0.0) {
    gl_Position = vec4(-0.05, -0.3, 0, 1);
  }
  else if (vertexId == 1.0) {
   gl_Position = vec4(0.25, 0.3, 0, 1);
  }
  else if (vertexId == 2.0) {
   gl_Position = vec4(0.0125, -0.3, 0, 1);
  }

  else if (vertexId == 3.0) {
   gl_Position = vec4(-0.05, 0.3, 0, 1);
  }
  else if (vertexId == 4.0) {
   gl_Position = vec4(0.25, 0.3, 0, 1);
  }
  else if (vertexId == 5.0) {
   gl_Position = vec4(-0.05, -0.3, 0, 1);
  }

  if (vertexId == 1.0 || vertexId == 2.0 || vertexId == 4.0) {
   v_color = vec4(1, 1, 1, 1);
  }
  else {
    v_color = vec4(1, 0, 0, 1);
  }

}
