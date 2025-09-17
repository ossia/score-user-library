/*{
  "DESCRIPTION": "Making A Grid Variation",
  "CREDIT": "minsu-kim-digipen (ported from https://www.vertexshaderart.com/art/FMuoFaTjjywnD7fJm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 16384,
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
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1684410565960
    }
  }
}*/

// Name : Minsu Kim
// Assignment : Exercise - Vertexshaderart : Making a Grid
// Course : CS250
// Spring 2023

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

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;

  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(cos(time / 2.), cos(time / 5.), cos(time / 10.), 1);
}
