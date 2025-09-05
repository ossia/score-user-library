/*{
  "DESCRIPTION": "math errors",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/Ekz3YzPYcEQyhT2z7)",
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
    "ORIGINAL_VIEWS": 20,
    "ORIGINAL_DATE": {
      "$date": 1501757517532
    }
  }
}*/

void main() {
  float id = vertexId + .1;
  float aspect = resolution.x / resolution.y;
  float across = floor(sqrt(vertexCount) * aspect);
  float down = floor(vertexCount / across);
  float x = mod(id, across);
  float y = floor(id / across);

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