/*{
  "DESCRIPTION": "TriangleVerticalSeq",
  "CREDIT": "alexisrubio96 (ported from https://www.vertexshaderart.com/art/4uB9s4qnD3rioJw9B)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 8,
  "PRIMITIVE_MODE": "LINE_STRIP",
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
      "$date": 1551484755957
    }
  }
}*/

void main(){

   float x = floor(vertexId / 2.0);
 float y = mod(vertexId + 1.0, 2.0);

   vec2 xy = vec2(x,y)*1.0;

 gl_Position = vec4(x, y, 0.0,10.0); //Posición final de un vertice
   v_color = vec4(1.0,0.0,0.0,1.0);
   gl_PointSize = 1.0;

}