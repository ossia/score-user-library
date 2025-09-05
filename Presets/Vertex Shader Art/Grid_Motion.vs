/*{
  "DESCRIPTION": "Grid Motion",
  "CREDIT": "rubinhuang9239 (ported from https://www.vertexshaderart.com/art/HtZXu6SRZeugBajhN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 2048,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1596329705041
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

   float xoff = sin(time + y * 0.2) * 0.1;
   float yoff = sin(time + x * 0.3) * 0.1;

    float ux = u*2.0-1.0 + xoff;
    float vy = v*2.0-1.0 + yoff;

   vec2 xy = vec2(ux,vy) * 0.70;

   gl_Position = vec4( xy, 0.0, 1.0);

   float sizeoff = sin(time + x * y *0.02) * 10.0;

   gl_PointSize = 15.0 + sizeoff;
   gl_PointSize *= 20.0/across;
   gl_PointSize *= resolution.x/600.0;

   v_color = vec4(ux + cos(sin(ux + time)), vy + cos(sin(vy + time)), 0.75,1.0);
}
