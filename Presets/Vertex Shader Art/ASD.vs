/*{
  "DESCRIPTION": "ASD",
  "CREDIT": "shtrompel (ported from https://www.vertexshaderart.com/art/ZoyrdxZiwDYNfzT53)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1529745957278
    }
  }
}*/

#define PI radians(180.)

void main() {
  float across = 50.;
  float x, y, dist;
  vec2 pos, a, b;

  //Calculate Position
  x = mod(vertexId, across);
  y = floor(vertexId / across);

  pos.x = x / across;
  pos.y = y / across;

  pos.x = pos.x * 2. - 1.;
  pos.y = pos.y * 2. - 1.;

  //Calculate distance from mouse
  dist = sqrt(pow(pos.x - mouse.x, 2.) + pow(pos.y - mouse.y, 2.));
  dist /= 1.25;
  dist = max(dist, 0.2);

  //Dividing position by distance
  pos /= dist;

  //Apply position
  gl_Position = vec4(pos.x, pos.y, 0, 1);

  gl_PointSize = 7.0;

  //float r, g, b;
  float r = (sin(time * 2.0 + PI / 2.75) + 1.) / 2.;
  float g = (cos(time * 1.5 + PI / 1.5) + 1.) / 2.;
  //b = (sin(time * 1.8 + PI / 2.0) + 1.) / 2.;

  v_color = vec4(r, g, 0, 1);
}
//