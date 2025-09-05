/*{
  "DESCRIPTION": "Grid",
  "CREDIT": "rubinhuang9239 (ported from https://www.vertexshaderart.com/art/RjKNeXgMi8SchMEXg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.11372549019607843,
    0.07450980392156863,
    0.26666666666666666,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1596325611598
    }
  }
}*/

void main() {
   float down = floor(sqrt(vertexCount));
   float across = floor (vertexCount/down);

   float x = mod(vertexId, across);
   float y = floor(vertexId / across);

   float u = x/ (across - 1.0);
   float v = y/ (across - 1.0);

  float ux = u*2.0-1.0;
  float vy = v*2.0-1.0;

 gl_Position = vec4(ux, vy,0.0,1.0);
 gl_PointSize = 10.0;
   gl_PointSize *= 20.0/across;
   gl_PointSize *= resolution.x/600.0;

   v_color = vec4(1.0);

}