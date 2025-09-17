/*{
  "DESCRIPTION": "Init",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/DwqqEvCDpZA7dj9qu)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1494938899781
    }
  }
}*/


// I get error when I type g1_Positon !!!
// so use this instead

void main(){

  gl_Position = vec4(0, 0, 0, 1);

  gl_PointSize = 10.0;

  v_color = vec4(1, 0, 0, 1);

}