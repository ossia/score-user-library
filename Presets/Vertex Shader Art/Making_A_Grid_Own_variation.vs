/*{
  "DESCRIPTION": "Making A Grid_Own variation",
  "CREDIT": "chaerinpark (ported from https://www.vertexshaderart.com/art/cTjJFwZcBSSW8d9gw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 277,
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
    "ORIGINAL_VIEWS": 51,
    "ORIGINAL_DATE": {
      "$date": 1684325118975
    }
  }
}*/

//Name : Chaerin Park
//Assignment : Exercise - Vertexshaderart : Making a Grid
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

  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float r = sin(time);
  float g = sin(time) + cos(time);
  float b = cos(time);

  v_color = vec4(r, g, b, 1);
}