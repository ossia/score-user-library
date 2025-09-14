/*{
  "DESCRIPTION": "\uc900\uc11d",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/fcxZGWMjswfrJWNLZ)",
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
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 66,
    "ORIGINAL_DATE": {
      "$date": 1569777780228
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
 float move = vertexId*10.0;

  float x= mouse.x ;
  float y=mouse.y;

  gl_Position = vec4(sin(move)+x,cos(move)+y, 0, 1);

  gl_PointSize = 30.0;

  float red=tan(time);
  float blue=cos(time);
  float green=tan(time);

  v_color=vec4(red,green,blue,1.0);
}