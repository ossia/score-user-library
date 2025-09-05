/*{
  "DESCRIPTION": "quad test",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/fwuLjHMQenJtNXJxZ)",
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
    "ORIGINAL_VIEWS": 62,
    "ORIGINAL_DATE": {
      "$date": 1533038888888
    }
  }
}*/

void main() {

  int vertID = int(vertexId);

  if (vertID == 0) {
    gl_Position = vec4(-0.025, -0.3, 0, 1);
  }
  else if (vertID == 1) {
   gl_Position = vec4(0.25, 0.3, 0, 1);
  }
  else if (vertID == 2) {
   gl_Position = vec4(0.0125, -0.3, 0, 1);
  }

  else if (vertID == 3) {
   gl_Position = vec4(-0.025, 0.3, 0, 1);
  }
  else if (vertID == 4) {
   gl_Position = vec4(0.25, 0.3, 0, 1);
  }
  else if (vertID == 5) {
   gl_Position = vec4(-0.025, -0.3, 0, 1);
  }

  if (vertID == 1 || vertID == 2 || vertID == 4) {
   v_color = vec4(1, 1, 1, 1);
  }
  else {
    v_color = vec4(1, 0, 0, 1);
  }

}
