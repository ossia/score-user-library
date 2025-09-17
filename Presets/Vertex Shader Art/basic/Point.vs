/*{
  "DESCRIPTION": "Point",
  "CREDIT": "iguacel (ported from https://www.vertexshaderart.com/art/xzFWA2bkiC4v8p9oX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.043137254901960784,
    0.0784313725490196,
    0.1568627450980392,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1672677938661
    }
  }
}*/

void main() {
  gl_Position = vec4(0, 0, 0, 1);
  gl_PointSize = 10.0;
  v_color = vec4(0,1,0,1);
}