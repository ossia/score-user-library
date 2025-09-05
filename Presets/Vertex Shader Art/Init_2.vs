/*{
  "DESCRIPTION": "Init 2",
  "CREDIT": "thetuesday night machines (ported from https://www.vertexshaderart.com/art/SoK3eJipBJGantxyd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 47,
    "ORIGINAL_DATE": {
      "$date": 1546167083483
    }
  }
}*/

void main() {

  float x = vertexId;
  float y = vertexId*2.;

  gl_Position = vec4(x, y, 0., 1.);

  // base size 100, plus sin(time) between 0 and 1 * 100
  gl_PointSize = 100. + (sin(time)/2.+.5)*100.;

  v_color = vec4(1., 0., 0., 1.);
}