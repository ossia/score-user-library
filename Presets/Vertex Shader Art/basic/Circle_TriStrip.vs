/*{
  "DESCRIPTION": "Circle_TriStrip",
  "CREDIT": "sergioerick (ported from https://www.vertexshaderart.com/art/fXX9cns72XG97J3rk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 164,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1551543812460
    }
  }
}*/

void main() {

  float squares = 80.0;
  float PI = 3.14159;

  float x = floor(vertexId / 2.0);
  float y = mod(vertexId, 2.0);

  float angle = (x/squares)*(2.0*PI);
  float r = y + 0.5;

  float x1 = r * cos(angle);
  float y1 = r * sin(angle);

  vec2 xy = vec2(x1,y1)*0.4;

  gl_Position = vec4(xy,0.0,1.0);
  v_color=vec4(0.0, 0.0,1.0,1.0);
  gl_PointSize = 10.0;

}