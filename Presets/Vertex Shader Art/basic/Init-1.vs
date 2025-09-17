/*{
  "DESCRIPTION": "Init",
  "CREDIT": "thetuesday night machines (ported from https://www.vertexshaderart.com/art/c5eMNzQN3L9wo8Bp5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 62,
    "ORIGINAL_DATE": {
      "$date": 1546165831327
    }
  }
}*/

void main() {

  float x = vertexId;
  float y = vertexId;

  gl_Position = vec4(x, y, 0., 1.);
  gl_PointSize = 10.;

  v_color = vec4(1., 0., 0., 1.);
}