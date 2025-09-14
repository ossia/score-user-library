/*{
  "DESCRIPTION": "\uc900\uc11d",
  "CREDIT": "wnstjr (ported from https://www.vertexshaderart.com/art/EG3pbFeZPLiS72ia5)",
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1554178984947
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float xoff = 0.0;
  float yoff = 0.0;

  vec2 xy = vec2(xoff, yoff)*2.5;

  gl_Position = vec4(xy, 0, 1);

  gl_PointSize *= 20.0 / across;
  gl_PointSize=abs(sin(time)*(mouse.x))* 500.0;

  float red=cos(time*2.0);
  float blue=sin(time*2.0);
  float green=tan(time*2.0);

  v_color=vec4(red,green,blue,1.0);
}