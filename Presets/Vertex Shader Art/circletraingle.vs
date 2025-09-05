/*{
  "DESCRIPTION": "circletraingle",
  "CREDIT": "alexisrubio96 (ported from https://www.vertexshaderart.com/art/iko4zHPGCfdPcBr5s)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 306,
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
      "$date": 1551650774904
    }
  }
}*/

void main(){

   float x = floor(vertexId);
 float y = mod(vertexId + 1.0, 2.0);

   float angle = x / 150.0 * radians(180.0);
   float radius = 2.0 - y;

   float ux = radius * cos(angle);
   float uy = radius * sin(angle);

   vec2 xy = vec2(ux,uy)*1.0;

 gl_Position = vec4(xy, 0.0,10.0); //Posición final de un vertice
   v_color = vec4(x,y,0.0,1.0);
   gl_PointSize = 1.0;

}