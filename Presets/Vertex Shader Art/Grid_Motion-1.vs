/*{
  "DESCRIPTION": "Grid Motion",
  "CREDIT": "rubinhuang9239 (ported from https://www.vertexshaderart.com/art/nERwc23zjdTrQfzjD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1596328223305
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

   gl_Position = vec4( ux + cos(sin(ux + time)) * 0.1, vy + cos(sin(vy + time))*0.1, 0.0, 1.0);

   gl_PointSize = 16.0 + sin(time)*12.0;
   gl_PointSize *= 20.0/across;
   gl_PointSize *= resolution.x/600.0;

   v_color = vec4(ux + cos(sin(ux + time)), vy + cos(sin(vy + time)), 0.75,1.0);

}
