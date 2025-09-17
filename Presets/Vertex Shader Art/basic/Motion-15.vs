/*{
  "DESCRIPTION": "Motion - Motion for extra",
  "CREDIT": "jaewoo.choi (ported from https://www.vertexshaderart.com/art/Xh6Hmvi8yPW6A6rFG)",
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1652946757708
    }
  }
}*/

//Name: Jaewoo.choi
//Assignment Name: Vertexshaderart : Motion_Extra
//Course Name: CS250
//Term&Year: 2022&Spring
void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float yoff = sin(time + y * 0.2) * 0.1;
  float xoff = sin(time + x * 0.3) * 0.2;
  xoff += abs(sin(time) * 0.2);
  yoff += cos(time) * 0.3;

  float ux = u * 2. - 1. + xoff;
  ux += u * 2. - 1. + yoff;

  float vy = v * 2. - 1. + yoff;
  vy = v * 2. - 1. + xoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0.9, 1) + sin(time) * 0.5;
  gl_Position += xoff;
  gl_Position += yoff;

  float soff = sin(time + x * y * .02) * 5.;
  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;
  v_color = vec4(abs(sin(time)), abs(ux), cos(time) * vy, 1);
}