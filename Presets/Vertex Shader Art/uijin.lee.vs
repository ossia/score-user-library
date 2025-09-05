/*{
  "DESCRIPTION": "uijin.lee",
  "CREDIT": "\uc758\uc9c4 (ported from https://www.vertexshaderart.com/art/9caDdikyJ7k4Q3o2L)",
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
    "ORIGINAL_VIEWS": 109,
    "ORIGINAL_DATE": {
      "$date": 1554196523821
    }
  }
}*/

/*your name : uijin.lee
the assignment number : assignment 3 extra credit
the course name : CS230
the term : Spring 2019
*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
  float m = vertexId ;

  gl_Position = vec4(m*mouse.x,m*mouse.y,0, 1);
  gl_PointSize = 5.0;

  v_color = vec4(sin(time), cos(time), tan(time), 1.0);

}