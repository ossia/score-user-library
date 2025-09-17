/*{
  "DESCRIPTION": "Motion",
  "CREDIT": "chaerinpark (ported from https://www.vertexshaderart.com/art/fjN25zTwqLYMCNkJ4)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 42,
    "ORIGINAL_DATE": {
      "$date": 1684411436071
    }
  }
}*/

//Name : Chaerin Park
//Assignment : Exercise - Vertexshaderart : Motion
//Course : CS250
//Spring 2023

void main()
{
 float down = floor(sqrt(vertexCount));
   float across = floor(vertexCount / down);

   float x = mod(vertexId, across);
   float y = floor(vertexId / across);

   float u = x / (across - 1.0);
   float v = y / (across - 1.0);

   float xoff = sin(time + y * 0.2) * 0.1;
   float yoff = sin(time + x * 0.3) * 0.2;

   float ux = u * 2.0 - 1.0 + xoff;
   float vy = v * 2.0 - 1.0 + yoff;

   vec2 xy = vec2(ux, vy) * 1.3;

   gl_Position = vec4(xy, 0, 1);

   float soff = sin(time + x) * 5.0;

   gl_PointSize = 15.0 + soff;
   gl_PointSize *= 20.0 / across;
   gl_PointSize *= resolution.x / 600.0;

   v_color = vec4(1, 0, 0, 1);
}
