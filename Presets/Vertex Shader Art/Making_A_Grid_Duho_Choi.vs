/*{
  "DESCRIPTION": "Making A Grid_Duho Choi",
  "CREDIT": "duhochoi (ported from https://www.vertexshaderart.com/art/JG27yEiRBewAYsMxB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 7873,
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
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1684333951490
    }
  }
}*/

// Name : Duho Choi
// Assignment : Exercise - Vertexshaderart : Making a Grid
// Course : CS250
// Term : Spring 2023

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

  gl_Position = vec4(sin(ux * 3.), sin(vy * 2.), 0, 1);

  gl_PointSize = 20.0;
  gl_PointSize *= 40. / across;
  gl_PointSize *= resolution.x / 1000.;

  v_color = vec4 (0.2, 0.5, 0.5, 1);

}
