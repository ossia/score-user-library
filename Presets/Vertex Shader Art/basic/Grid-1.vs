/*{
  "DESCRIPTION": "Grid",
  "CREDIT": "iguacel (ported from https://www.vertexshaderart.com/art/KRmBguLvKHcjPJHpn)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 25,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.07058823529411765,
    0.06666666666666667,
    0.06666666666666667,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 10,
    "ORIGINAL_DATE": {
      "$date": 1672680549146
    }
  }
}*/

void main() {

  float down = floor(sqrt(vertexCount));

  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float scale = 0.9;
  vec2 xy = vec2(ux, vy) * scale;

  gl_Position = vec4(xy, 0., 1.);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(0., .2, 0., 1.);
}