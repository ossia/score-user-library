/*{
  "DESCRIPTION": "test0",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/nbFWWPZ79M6W6WTNB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.29411764705882354,
    0.5882352941176471,
    0.9450980392156862,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 86,
    "ORIGINAL_DATE": {
      "$date": 1521575045177
    }
  }
}*/


void main() {
  gl_PointSize = 10.0;
  vec2 xy = vec2(vertexId / 3.0, vertexId / 3.0);
  gl_Position = vec4(xy,0.0,1.0);
  v_color = vec4(1.0,0.0,0.0,1.0);
}