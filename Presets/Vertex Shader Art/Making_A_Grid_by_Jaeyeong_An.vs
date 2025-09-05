/*{
  "DESCRIPTION": "Making A Grid by Jaeyeong An - From vertexshaderart's Lessons follow along with Lesson 01 - Making a Grid. ",
  "CREDIT": "jaeyeong-an (ported from https://www.vertexshaderart.com/art/hXDoWkGSTBFBQGXnN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
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
    "ORIGINAL_VIEWS": 50,
    "ORIGINAL_DATE": {
      "$date": 1684324332351
    }
  }
}*/

//Name : Jaeyeong An
//Assignment : Exercise - Vertexshaderart : Making a Grid
//Course : CS250
//Term : 2023 Fall

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. -1.;
  float vy = v * 2. -1.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1, 0, 0, 1);

}