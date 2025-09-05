/*{
  "DESCRIPTION": "Making A Grid-JongHyeon Lee",
  "CREDIT": "jonghyeon-lee-digipen (ported from https://www.vertexshaderart.com/art/BCqiiXBgBXYHTqw6G)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
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
    "ORIGINAL_VIEWS": 38,
    "ORIGINAL_DATE": {
      "$date": 1684323391986
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

  // Calculate color based on time
  float red = sin(time);
  float green = cos(time);
  float blue = sin(time + 1.0);

  v_color = vec4(red, green, blue, 1);
}