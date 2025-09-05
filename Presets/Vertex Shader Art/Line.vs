/*{
  "DESCRIPTION": "Line",
  "CREDIT": "iguacel (ported from https://www.vertexshaderart.com/art/84TzMFEGdJQDyrLAw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.12549019607843137,
    0.11372549019607843,
    0.11372549019607843,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1672679019966
    }
  }
}*/

void main() {

  float x = vertexId / 100.;
  float y = vertexId / 100.;

  gl_Position = vec4(x, y, 0., 1.);
  gl_PointSize = 3.0;
  v_color = vec4(0., 1., 0., 1.);
}