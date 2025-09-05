/*{
  "DESCRIPTION": "Exercise - Vertexshaderart : Motion_sehun.kim - Exercise - Vertexshaderart_sehun.kim : Motion",
  "CREDIT": "sehoonkim-digipen (ported from https://www.vertexshaderart.com/art/mAzBS3pdAM6PxJku9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 12010,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1652949017696
    }
  }
}*/

/*
Name : Sehun Kim
assignment name : Exercise - Vertexshaderart : Motion
course name : CS250
term : 2022 Spring
*/
void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.01) * 0.5;
  float yoff = sin(time + x ) * sin(time);

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(sin(xy), 0, 1);

  float soff = sin(time + x * y * .02) * 5.;
  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 500.0;
  v_color = (vec4(0.75-ux*ux, 0.75-vy*vy, 0.75-ux*vy, 1));
}