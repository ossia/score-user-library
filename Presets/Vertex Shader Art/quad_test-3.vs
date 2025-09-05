/*{
  "DESCRIPTION": "quad test",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/jC6yjCA9eDW8oasNA)",
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
    "ORIGINAL_VIEWS": 77,
    "ORIGINAL_DATE": {
      "$date": 1533039174716
    }
  }
}*/

void main() {

  int vertID = int(vertexId);

  float left = -0.025;
  float rightTop = 0.5;
  float rightBottom = 0.0125;

  if (vertID == 0) {
    gl_Position = vec4(left, -0.3, 0, 1);
  }
  else if (vertID == 1) {
   gl_Position = vec4(rightTop, 0.3, 0, 1);
  }
  else if (vertID == 2) {
   gl_Position = vec4(rightBottom, -0.3, 0, 1);
  }

  else if (vertID == 3) {
   gl_Position = vec4(left, 0.3, 0, 1);
  }
  else if (vertID == 4) {
   gl_Position = vec4(rightTop, 0.3, 0, 1);
  }
  else if (vertID == 5) {
   gl_Position = vec4(left, -0.3, 0, 1);
  }

  if (vertID == 1 || vertID == 2 || vertID == 4) {
   v_color = vec4(1, 1, 1, 1);
  }
  else {
    v_color = vec4(1, 0, 0, 1);
  }

}
