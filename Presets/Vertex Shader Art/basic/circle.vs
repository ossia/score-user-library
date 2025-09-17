/*{
  "DESCRIPTION": "circle",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/AC57qxXZiP5Xt3MPo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "CSS",
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
      "$date": 1496650006733
    }
  }
}*/

void main() {
  //float density = 2.;
  float density = floor(vertexCount / 1000.) + 1.;

  //float xoff = -0.5* (density / 20.);
  //float yoff = -0.5 * (density / 20.);

  float xoff = -1. * (density / 50.);
  float yoff = -1. * (density / 50.);
  float ux = 0.1 * (20. / density);
  float uy = 0.1 * (20. / density);
  float x = mod(vertexId , density);
  float y = mod(floor(vertexId / density), density);

  gl_Position = vec4(x * ux + xoff, y * uy + yoff, 0, 1);
  //gl_PointSize = mod(vertexId, density * density) / 5.;
  gl_PointSize = 200. / density;
  v_color = vec4(1, 0, 0, 1);
}