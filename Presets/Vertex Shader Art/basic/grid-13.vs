/*{
  "DESCRIPTION": "grid - main",
  "CREDIT": "moon-jong (ported from https://www.vertexshaderart.com/art/wP4tHTACwohNdomhd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1606,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.050980392156862744,
    0.047058823529411764,
    0.047058823529411764,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1679620803252
    }
  }
}*/

void main() {

   float down = floor(sqrt(vertexCount));
 float across = floor(vertexCount / down);
   float x = mod(vertexId, across);
   float y = floor(vertexId / across);

   float u = x / (across - 1.);
   float v = y / (across - 1.);

   float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = cos(time + x * 0.3) * 0.2;
   float soff = sin(time + x) * 5.;

   float ux = u * 2. - 1. + xoff;
    float vy = v * 2. - 1. + yoff;

   vec2 xy = vec2(ux, vy) * 1.3;

 gl_Position = vec4(xy, 0, 1);
   gl_PointSize = 15.0 + soff;
 gl_PointSize *= 20.0 / across;

   gl_PointSize *= resolution.x / 600.;

 v_color = vec4(xoff * 10., yoff * 10., soff * 10., 1);

}