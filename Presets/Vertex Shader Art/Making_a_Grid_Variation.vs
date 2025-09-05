/*{
  "DESCRIPTION": "Making a Grid Variation",
  "CREDIT": "daehyeon.kim (ported from https://www.vertexshaderart.com/art/Q2oHwSyr3NpT7jokA)",
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
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1652884760741
    }
  }
}*/

//Daehyeon Kim
//Make a grid
//CS250
//Spring, 2022

void main() {
  float factor = sin(time) * 5. + 6.;

  float down = floor(sqrt(vertexCount)) * factor;
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  x += sin(time) * 5.;
  y += cos(time) * 8.;

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(sin(time) * 0.5 + 0.5,cos(time) * 0.5 + 0.5,0,1);
}