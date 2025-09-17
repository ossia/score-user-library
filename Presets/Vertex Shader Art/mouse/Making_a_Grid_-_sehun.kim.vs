/*{
  "DESCRIPTION": "Making a Grid - sehun.kim - Exercise - Vertexshaderart : Making a Grid",
  "CREDIT": "sehoonkim-digipen (ported from https://www.vertexshaderart.com/art/c7BfoLHoLFBdJ5iYy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 29459,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1652848486714
    }
  }
}*/

/*
Name : Sehun Kim
assignment name : Exercise - Vertexshaderart : Making a Grid
course name : CS250
term : 2022 Spring
*/
void main() {

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId , across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 20.;
  gl_PointSize -= 100. * (distance(ux , mouse.x)) * (distance(vy , mouse.y));
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = (vec4(ux*ux, 1.0-vy, u*u * 2.0 - 1., 1));
}