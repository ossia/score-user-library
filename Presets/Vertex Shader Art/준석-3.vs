/*{
  "DESCRIPTION": "\uc900\uc11d",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/TFMzciLhhyBhYRKW5)",
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
    "ORIGINAL_VIEWS": 10,
    "ORIGINAL_DATE": {
      "$date": 1561458819716
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
 float move = vertexId*2.0;

  float x= mouse.x ;
  float y=mouse.y;

  gl_Position = vec4(sin(move)+x,cos(move)+y, 0, 1);

  gl_PointSize = 30.0;

  float red=sin(time);
  float blue=cos(time);
  float green=tan(time);

  v_color=vec4(red,green,blue,1.0);
}