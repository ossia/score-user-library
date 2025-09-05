/*{
  "DESCRIPTION": "Learn Vertex Shaders",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/tF4ynbNrnHawnus9p)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 69,
    "ORIGINAL_DATE": {
      "$date": 1498138091988
    }
  }
}*/

void main() {
 gl_PointSize = 10.0;
   gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}