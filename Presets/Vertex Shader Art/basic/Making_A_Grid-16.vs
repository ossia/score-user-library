/*{
  "DESCRIPTION": "Making A Grid",
  "CREDIT": "junsujang-digipen (ported from https://www.vertexshaderart.com/art/hQ22f6sNbz8Dczs4G)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.33725490196078434,
    0.2823529411764706,
    0.2823529411764706,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 16,
    "ORIGINAL_DATE": {
      "$date": 1652623872012
    }
  }
}*/

// Junsu Jang
// Exercise Making A Grid
// CS250
// Spring/2022

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId/across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0., 1.);

  gl_PointSize = 10.0;
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1,0,0,1);

}