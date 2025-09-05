/*{
  "DESCRIPTION": "Motion.seongwon.jang",
  "CREDIT": "seongwon.jang (ported from https://www.vertexshaderart.com/art/HLctHNLy3GzgrxTpT)",
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
      "$date": 1652964257980
    }
  }
}*/

/*
Seongwon Jang
cs250
Making a grid
2022 spring
*/

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);
   //float z = abs(sin(x*y));

  float xoff = -abs(sin(time + y * 0.2)) * 0.2;
  float yoff = -abs(sin(time + x * 0.3)) * 0.3;
 // float zoff = abs(sin(time + (x+y) * 0.4)) * 0.4;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;
  float zz = 0.;
  vec2 xy = vec2(ux,vy) * 1.3;

  gl_Position = vec4(xy,0,1);

  float soff = sin(time + x* y* 0.02) * 50.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(0, 0, 1, 1);
}