/*{
  "DESCRIPTION": "D1_365",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/LbkZcKYz5Z7nbCP4s)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1635118350935
    }
  }
}*/

void main(){

  float x = vertexId / 10.;

  gl_Position = vec4(0, 0, 0, 1);

  gl_PointSize = 10.;

  v_color = vec4(1, 0, 0, 1);

}