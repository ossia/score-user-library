/*{
  "DESCRIPTION": "jaewoo.choi",
  "CREDIT": "\uc7ac\uc6b0 (ported from https://www.vertexshaderart.com/art/2LCzyt3dGEKL3dcTG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 6084,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 168,
    "ORIGINAL_DATE": {
      "$date": 1554195403669
    }
  }
}*/

/*------------------------------------------------------------------------
Author : jaewoo choi
Assignment Name/Number : Shader/3 (Extra Credit)
Course Name : CS230
Term : Spring 2019
------------------------------------------------------------------------*/
#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main()
{
  float point = vertexId*3.;

  gl_Position = vec4(sin(point)*mouse.x,cos(point)*mouse.y,0,1);

  gl_PointSize =55.;

  v_color = vec4(sin(time),cos(time),tan(time),1.0);

}