/*{
  "DESCRIPTION": "Cs230 - adding header",
  "CREDIT": "\ub3c4\uc601 (ported from https://www.vertexshaderart.com/art/itFYHyLvFpbtiqvaP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1554213556193
    }
  }
}*/

/*------------------------------------------------------------------------
File Name:Extra Credit-Vertex Shader
Course name: Cs230Kr
Assignment name/Number:Shader Programming Assignment/3
Author:Doyeong Yi
Term:Spring 2019
------------------------------------------------------------------------*/
void main()
{
   float value = vertexId*10.0;
// Put value multiplied by vertexid and 10.0 for flotat type variable which named “value”

 float x =mouse.x;
 // Put the float type variable that accepts the mouse's x coordinate
 float y = mouse.y;
   // Put the float type variable that accepts the mouse's y coordinate

  float snd = texture(sound, vec2(0, 0)).r;
 //Put sound value in float type variable which named “snd”

   gl_Position = vec4(cos(value), sin(value), 0, abs(snd*2.0));
   //set position
   gl_PointSize = 50.0;
   //set point size 50.0

   v_color = vec4(cos(x), sin(y), tan(x*y), 1);
 //set color
}
