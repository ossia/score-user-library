/*{
  "DESCRIPTION": "JJEONDA",
  "CREDIT": "\ucca0\uc9dc (ported from https://www.vertexshaderart.com/art/6N22GnCbsgYC6faeW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1554181253984
    }
  }
}*/

/*------------------------------------------------------------------------
Author = chulseung.lee
Assignment Name/Number = Shader/3 (Extra Credit)
Course Name = CS230
Term = Spring 2019
------------------------------------------------------------------------*/

void main() {
  gl_Position = vec4(mouse.x, mouse.y, 0, 1);
  gl_PointSize = 300.0;

  gl_PointSize *= abs(mouse.x)+abs(mouse.y);

  v_color = vec4(sin(time*10.0), mouse.x * mouse.y, 1.0, 1);
}