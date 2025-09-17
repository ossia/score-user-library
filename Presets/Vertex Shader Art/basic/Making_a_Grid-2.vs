/*{
  "DESCRIPTION": "Making a Grid",
  "CREDIT": "jonghyeon-lee-digipen (ported from https://www.vertexshaderart.com/art/a9PxcWZgDCKCjv5qK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 30,
    "ORIGINAL_DATE": {
      "$date": 1684322954383
    }
  }
}*/

//Name: JongHyeon Lee
//Assignment: Making a Grid
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

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1, 0, 0, 1);
}