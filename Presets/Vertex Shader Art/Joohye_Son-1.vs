/*{
  "DESCRIPTION": "Joohye Son",
  "CREDIT": "juhye (ported from https://www.vertexshaderart.com/art/MdL5GN8abavG8YvBs)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1554202462015
    }
  }
}*/

/*------------------------------------------------------------------------
Author : Joohye Son
Assignment Name/Number : Shader/3 (Extra Credit)
Course Name : CS230
Term : Spring 2019
------------------------------------------------------------------------*/
#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {

gl_Position=vec4(sin(time)*mouse.x, cos(time)*mouse.y*cos(vertexId), 0, 1);
  gl_PointSize=20.;
  v_color=vec4(sin(time), cos(time), tan(time), 1);

}