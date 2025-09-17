/*{
  "DESCRIPTION": "chulseung.lee - this is shader assignment extra",
  "CREDIT": "\ucca0\uc9dc (ported from https://www.vertexshaderart.com/art/dMZsJyyPW2EgjrH4P)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 950,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.48627450980392156,
    0.48627450980392156,
    0.48627450980392156,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 291,
    "ORIGINAL_DATE": {
      "$date": 1554181654220
    }
  }
}*/

/*------------------------------------------------------------------------
Author = chulseung.lee
Assignment Name/Number = Shader/3 (Extra Credit)
Course Name = CS230
Term = Spring 2019
------------------------------------------------------------------------*/
#define PI 3.1415926

void main()
{
  float radian = vertexId / (vertexCount) * 3.0 * PI;
  radian *= 3.0;

  gl_Position = vec4( cos(radian * mouse.x), sin(radian * mouse.y), 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= abs(mouse.x)+abs(mouse.y);

  v_color = vec4(sin(time*100.0), tan(time*5.0), cos(time*5.0), 1);
}