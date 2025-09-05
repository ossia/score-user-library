/*{
  "DESCRIPTION": "Motion",
  "CREDIT": "jeminshin2 (ported from https://www.vertexshaderart.com/art/b3HJWpHiePeAo4JrM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1684414594680
    }
  }
}*/


void main()
{
 float down = floor(sqrt(vertexCount));
   float across = floor(vertexCount / down);

   float x = mod(vertexId, across);
   float y = floor(vertexId / across);

   float u = x / (across - 1.0);
   float v = y / (across - 1.0);

   float xoff = sin(time + y * 2.0 ) * 0.5;
   float yoff = cos(time + x * 3.0) * 0.5;

   float ux = u * 2.0 - 1.0 * xoff;
   float vy = v * 2.0 - 1.0 + yoff;

   vec2 xy = vec2(ux , vy) * 1.3;

   gl_Position = vec4(xy, 0, 1);

   gl_PointSize = 15.0 ;
   gl_PointSize *= 20.0 / across;
   gl_PointSize *= resolution.x / 600.;

   v_color = vec4(1, 0.5, 0.5, 1);
}