/*{
  "DESCRIPTION": "math errors - Removed floor() and everything is on an angle",
  "CREDIT": "macro (ported from https://www.vertexshaderart.com/art/xsSZN6pMk7iANGyTE)",
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
    "ORIGINAL_VIEWS": 33,
    "ORIGINAL_DATE": {
      "$date": 1501978082735
    }
  }
}*/

void main() {
  float aspect = resolution.x / resolution.y;
  float across = (sqrt(vertexCount) * aspect);
  float down = (vertexCount / across);
  float x = mod(vertexId, across);
  float y = (vertexId / across);

  float u = x / (across - 1.);
  float v = y / (down - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float pointScale = min(
    20. / across * resolution.x / 600.0,
    20. / down * resolution.y / 600.0);

  gl_Position = vec4(vec2(ux, vy) * .75, 0, 1);
  gl_PointSize = 15.0;
  gl_PointSize *= pointScale;

  v_color = vec4(1, 0, 0, 1);
}