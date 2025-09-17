/*{
  "DESCRIPTION": "Motion_minseok_kim",
  "CREDIT": "minseok.kim (ported from https://www.vertexshaderart.com/art/yCjeKmDJjLWcwymYt)",
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1684392494986
    }
  }
}*/

//Name : minseok kim
//Assignment : Exercise - Vertexshaderart : Motion
//Course : CS250
//Term : Spring 2023
void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.1) * 0.9;
  float yoff = sin(time + x * 0.1) * 0.7;

  float ux = u * 2. - 1. + xoff;

  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * 0.009) * 20.;

  gl_PointSize = 1.0 + soff;
  gl_PointSize *= 10. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(sin(time),1,cos(time),1);
}
