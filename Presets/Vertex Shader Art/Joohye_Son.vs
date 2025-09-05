/*{
  "DESCRIPTION": "Joohye Son",
  "CREDIT": "juhye (ported from https://www.vertexshaderart.com/art/2bWezECppzztDLn4T)",
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
    "ORIGINAL_VIEWS": 161,
    "ORIGINAL_DATE": {
      "$date": 1554203215450
    }
  }
}*/

/*------------------------------------------------------------------------
Author : Joohye Son
Assignment Name/Number : Shader/3 (Extra Credit)
Course Name : CS230
Term : Spring 2019
------------------------------------------------------------------------*/

void main() {

 float Id=vertexId;
 float x=mouse.x;
 float y=mouse.y;
 float xTime=sin(time);
 float yTime=cos(time);

 gl_Position=vec4(xTime*x, yTime*y*cos(Id), 0, 1);
 gl_PointSize=20.;
 float zTime=tan(time);
 v_color=vec4(xTime, yTime, zTime, 1);

}