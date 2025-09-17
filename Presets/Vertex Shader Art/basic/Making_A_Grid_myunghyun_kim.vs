/*{
  "DESCRIPTION": "Making A Grid_myunghyun,kim",
  "CREDIT": "myunghyunkim0227 (ported from https://www.vertexshaderart.com/art/vSoYhoMHS2k2S8ueR)",
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
    "ORIGINAL_VIEWS": 35,
    "ORIGINAL_DATE": {
      "$date": 1684325239751
    }
  }
}*/

//Name: Myunghyun Kim
//Assignment: Exercise - Vertexshaderart : Making a Grid
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

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float red = sin(time) * 4.;
  float blue = sin(time) * 4.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 300.;

  v_color = vec4(red, 0, blue, 1);
}