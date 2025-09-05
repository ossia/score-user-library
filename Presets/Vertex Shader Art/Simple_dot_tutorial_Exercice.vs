/*{
  "DESCRIPTION": "Simple dot tutorial/Exercice",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/7QLuHLmctdsezmmxr)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1541026147780
    }
  }
}*/

////////////////////////////////////////////////////////////
//Super Simple dot example
//Very simple vertex shader initiation with comments (work in progress)
////////////////////////////////////////////////////////////

//Vertices number (top menu) is on "1" means we are drawing only one vertice/dot (maximum would be 100000 on vertexshaderart.com)
//Render mode (top menu) is on "POINTS" means we are interpreting consecutive vertices as simple points.
//All lines starting with "//" are only here for comments and do not affect the final shader program

void main(){

  //1. SETTING THE DOT SIZE:
  //Exercise : try to change the value 15.0 to 30.0 and see the size of the point changes

  gl_PointSize = 15.0;

  //2. SETTING THE DOT POSITION : vec4(horizontal position, vertical position, depth position, 1.);
  //Note: values range from -1. to 1. : for first component -1. would be top left of the screen and 1. would be top right of the screen.

  //Exercise : Try to change the FIRST 0. in vec4(0., 0., -1., 1.) to vec4(0.5, 0., -1., 1.) and see the position of the point changes HORIZONTALLY
  //Exercise : Try to change the SECOND 0. in vec4(0., 0., -1., 1.) to vec4(0., 0.5, -1., 1.) and see the position of the point changes VERTICALLY

  gl_Position = vec4(0., 0., 0., 1.);

  //3. SETTING THE DOT COLOR :
  //Each number in the vec4() below is for vec4(red, green, blue, alpha) hence, vec4(1., 1., 1., 1.0) is for white color
  //Note: values range from 0. to 1.

  //Exercise : try to change vec4(1., 1., 1., 1.0) to vec4(1., 0., 0., 1.0) and see the point is now red
  //Exercise : try to change vec4(1., 1., 1., 1.0) to vec4(0., 1., 0., 1.0) and see the point is now green
  //Exercise : try to change vec4(1., 1., 1., 1.0) to vec4(0., 0., 1., 1.0) and see the point is now blue

  v_color = vec4(1., 1., 1., 1.);
}