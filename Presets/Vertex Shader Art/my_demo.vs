/*{
  "DESCRIPTION": "my_demo",
  "CREDIT": "colin3dmax (ported from https://www.vertexshaderart.com/art/WhEz6A2JeXrzqtrhZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 9732,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.01568627450980392,
    0.01568627450980392,
    0.047058823529411764,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1596977660648
    }
  }
}*/

void main(){
   float down = floor(sqrt(vertexCount));
   float across = floor(vertexCount / down);

   float x = mod(vertexId , across);
   float y = floor(vertexId / across);

   float u = x / (across - 1.);
   float v = y / (across - 1.);

   float ux = u * 2. - 1.;
   float vy = v * 2. - 1.;

 gl_Position = vec4(ux, vy, 0.0, 1.0);

   gl_PointSize = 10.0;
   gl_PointSize *= 20./across;

   v_color = vec4(1.0, 0.0, 0.0, 1.0);
}