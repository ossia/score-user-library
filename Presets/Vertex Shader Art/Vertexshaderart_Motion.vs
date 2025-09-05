/*{
  "DESCRIPTION": "Vertexshaderart : Motion",
  "CREDIT": "yejin-shin (ported from https://www.vertexshaderart.com/art/s5eywpAoRQGmsD8Dq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.7254901960784313,
    0.8392156862745098,
    0.8941176470588236,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1684410515157
    }
  }
}*/

//Name : Yejin Shin
//Assignment : Vertexshaderart - Motion
//Course : CS250
//Spring, 2023

void main()
{
 float down = floor(sqrt(vertexCount));
 float across = floor(vertexCount / down);

 float x = mod(vertexId, across);
 float y = floor(vertexId/ across);

 float u = x / (across - 1.);
 float v = y / (across - 1.);

 float xoff = cos(time + y * 0.3) * 0.5;
 float yoff = cos(time + y * 0.3) * 0.2;

 float ux = u * 2. -1. + xoff;
 float vy = v * 2. -1. + yoff;

 vec2 xy = vec2(ux, vy) * 1.3;

   gl_Position = vec4(xy, 0, 1);

 float soff = sin(time + x * y * 0.02) * 5.;

 gl_PointSize = 25.0 * soff;
 gl_PointSize *= 20. / across;
 gl_PointSize *= resolution.x / 600.;

 v_color = vec4(0.178, 0.221, 0.239, 0.5);
}