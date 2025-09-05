/*{
  "DESCRIPTION": "Making A Grid with Colors",
  "CREDIT": "rudy2 (ported from https://www.vertexshaderart.com/art/98PzHFry4xqmuj7qt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 400,
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
    "ORIGINAL_VIEWS": 63,
    "ORIGINAL_DATE": {
      "$date": 1646381063457
    }
  }
}*/

// Rudy Castan
// Exercise Making A Grid with Colors
// CS250 Spring 2022

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId/across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 800.;

  v_color = 0.5*(vec4(1,0,0,1)+vec4(ux*ux, 1.0-vy, u*u * 2.0 - 1., 1));

}