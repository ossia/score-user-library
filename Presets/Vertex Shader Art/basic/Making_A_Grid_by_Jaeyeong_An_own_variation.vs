/*{
  "DESCRIPTION": "Making A Grid by Jaeyeong An(own variation) - Duplicate the shader and tweak it to make my variation",
  "CREDIT": "jaeyeong-an (ported from https://www.vertexshaderart.com/art/fSz8brGjX9TATFZLC)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 41,
    "ORIGINAL_DATE": {
      "$date": 1684325983625
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

  float ux = u * 2. -1. * sin(time);
  float vy = v * 2. -1. * cos(time);

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 500. ;

  v_color = vec4(sin(time), cos(time), 0, 1);

}