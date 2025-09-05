/*{
  "DESCRIPTION": "Making A Grid - jaewoo.choi",
  "CREDIT": "\uc7ac\uc6b0 (ported from https://www.vertexshaderart.com/art/965mBDin8f5mMFKoZ)",
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
      "$date": 1652854039852
    }
  }
}*/

void main() {

  gl_Position = vec4(0, 1, 0, 1);

  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);

}