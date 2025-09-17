/*{
  "DESCRIPTION": "Motion_myunghyun.kim",
  "CREDIT": "myunghyunkim0227 (ported from https://www.vertexshaderart.com/art/k92jG6hXfdYZmDDxp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 7000,
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
      "$date": 1684425830688
    }
  }
}*/

//Name: Myunghyun Kim
//Assignment: Exercise - Vertexshaderart : Motion
//Course: CS250
//Term: Spring 2023

void main()
{
 float down = floor(sqrt(vertexCount));
   float across = floor(vertexCount / down);

   float x = mod(vertexId, across);
   float y = floor(vertexId / across);

   float u = x / (across - 1.);
   float v = y / (across - 1.);

   float xoff = sin(time + y * 0.2) * 0.1;
   float yoff = sin(time + x * 0.3) * 0.2;

   float ux = u * 2. - 1. + xoff;
   float vy = v * 5. - 1. + yoff;

   float red = sin(time) * 4.;
   float blue = sin(time) * 4.;

   vec2 xy = vec2(ux, vy) * 1.;

   gl_Position = vec4(xy, 0, 1);

   float soff = sin(time + x) * 5.;

   gl_PointSize = 15.0 + soff;
   gl_PointSize *= 20.0 / across;
   gl_PointSize *= resolution.x / 600.0;

   v_color = vec4(red, 0, blue, 1);
}
