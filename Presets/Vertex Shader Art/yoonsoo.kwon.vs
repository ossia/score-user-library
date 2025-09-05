/*{
  "DESCRIPTION": "yoonsoo.kwon",
  "CREDIT": "\uc724\uc218 (ported from https://www.vertexshaderart.com/art/w5XY5hp6r86GpTyLE)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 186,
    "ORIGINAL_DATE": {
      "$date": 1554177518810
    }
  }
}*/

/*------------------------------------------------------------------------
Author : yoonsoo.kwon
Assignment Name/Number : Shader/3 (Extra Credit)
Course Name : CS230
Term : Spring 2019
------------------------------------------------------------------------*/

void main()
{
  float value = vertexId/10.;

  gl_Position = vec4(mouse.x*value , mouse.y*value , 0,1);
  gl_PointSize = abs(sin(time+value))*50.;

  v_color = vec4(sin(time), cos(time), tan(time), 1);
}