/*{
  "DESCRIPTION": "Making a Grid",
  "CREDIT": "seongwon.jang (ported from https://www.vertexshaderart.com/art/9GCFDmZiEXGbgKMny)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1652841824236
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

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);
  gl_PointSize = 15.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1, 0, 0, 1);
}