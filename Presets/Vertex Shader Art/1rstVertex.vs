/*{
  "DESCRIPTION": "1rstVertex",
  "CREDIT": "alexisrubio96 (ported from https://www.vertexshaderart.com/art/Hv927AXio5i8HPs2J)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 400,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1551481178139
    }
  }
}*/

void main(){
   float width = 20.0;

   float x = mod(vertexId, width);
 float y = floor(vertexId / width);

   float u = x / (width - 1.0);
   float v = y / (width - 1.0);

   float xOffset = cos(time + y *0.2) * 0.1;
   float yOffset = sin(time + x * 0.3) * 0.1;

   float ux = u *2.0 -1.0 + xOffset;
   float vy = v *2.0 -1.0 + yOffset;

   vec2 xy = vec2(ux, vy) * 1.2;

 gl_Position = vec4(xy,0.0,1.0); //Posición final de un vertice
   v_color = vec4(1.0,0.0,0.0,1.0);
   gl_PointSize = 10.0;

}