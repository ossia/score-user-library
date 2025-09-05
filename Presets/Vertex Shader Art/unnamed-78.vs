/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "makavelli3145 (ported from https://www.vertexshaderart.com/art/LwRP8tRgdnHBEYtuM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 2340,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.09411764705882353,
    0.14901960784313725,
    0.611764705882353,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1624968058796
    }
  }
}*/

void main(){

   float x1 = vertexId/ 10.;
   float y1 = vertexId/10.;
   y1 = y1*y1;

   float x2 = mod(vertexId, 10.0);
   float y2 = floor(vertexId/10.0);

   float x3 = x2/10.0;
   float y3 = y2/10.0;

   //gl_Position = vec4(0, 0, 0, 1);
    //gl_Position = vec4(x, 0, 0, 1);
   //gl_Position = vec4(x1, y1, 0, 1);
   //gl_Position = vec4(x2, y2, 0, 1);
   gl_Position = vec4(x3, y3, 0, 1);

   gl_PointSize = 10.0;

   //Note that v_color is unique to vertexshaderart
   v_color = vec4(1, 0, 0, 1);

}