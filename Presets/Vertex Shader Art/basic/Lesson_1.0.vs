/*{
  "DESCRIPTION": "Lesson 1.0",
  "CREDIT": "hamad (ported from https://www.vertexshaderart.com/art/8ZzuRWYAZeNEN3L4m)",
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1486820270355
    }
  }
}*/

void main () {
 gl_Position = vec4(0, 0, 0, 1); //normalized device coordinate

   gl_PointSize = 10.0;

   v_color = vec4(1, 0, 0, 1);
}