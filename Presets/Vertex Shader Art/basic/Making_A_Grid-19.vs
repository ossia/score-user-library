/*{
  "DESCRIPTION": "Making A Grid",
  "CREDIT": "minjae-yu (ported from https://www.vertexshaderart.com/art/xgQQX7WZ4GhGTRqMt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 4928,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.11764705882352941,
    0.11372549019607843,
    0.3254901960784314,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1684302948390
    }
  }
}*/

//Name : MINJAE YU
//Assignment : Making a Grid
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

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux * cos(time), vy * sin(time), 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(cos(time), sin(time), cos(time), 1);
}