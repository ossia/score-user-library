/*{
  "DESCRIPTION": "Making A Grid - Sangbeom Kim - Making A Grid - Sangbeom Kim",
  "CREDIT": "sangbeom.kim (ported from https://www.vertexshaderart.com/art/h2d7j2tEBmEKvpKGQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 3985,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1652808733293
    }
  }
}*/

//CS250 Spring 2022
//Sangbeom Kim
//Exercise - Vertexshaderart : Making a Grid Assignment

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. -1.;
  float vy = v * 2. -1.;

  gl_Position = vec4(ux, vy, 0, 1);
  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(u * u, v * v, 1. - u - v, 1.);
}