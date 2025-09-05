/*{
  "DESCRIPTION": "hello",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/kFydmLK7cBEcShhrj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.1411764705882353,
    0.32941176470588235,
    0.5803921568627451,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 34,
    "ORIGINAL_DATE": {
      "$date": 1689608062172
    }
  }
}*/


void main() {
 gl_Position = vec4(1, 0, 0, 0);

   gl_PointSize = 10.0;

   v_color = vec4(1, 0, 0, 1);
}