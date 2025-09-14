/*{
  "DESCRIPTION": "sangmin.kim - this is shader assignment extra",
  "CREDIT": "\uc0c1\ubbfc (ported from https://www.vertexshaderart.com/art/jmoBvZevCB2QeEtAN)",
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
    "ORIGINAL_VIEWS": 194,
    "ORIGINAL_DATE": {
      "$date": 1554177801202
    }
  }
}*/

/*------------------------------------------------------------------------
Author = sangmin.kim
Assignment Name/Number = Shader/3 (Extra Credit)
Course Name = CS230
Term = Spring 2019
------------------------------------------------------------------------*/
void main()
{
  gl_Position = vec4(0, 0, 0, 1);
  gl_PointSize = 150.;

  gl_PointSize *= sin(time * 8.);
  gl_PointSize *= 3.;

  v_color = vec4(mouse.x, mouse.y, mouse.x + mouse.y, 1);
}