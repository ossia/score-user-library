/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/kwpkNNSAmpsM6G7DB)",
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
    0.054901960784313725,
    0.25882352941176473,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 75,
    "ORIGINAL_DATE": {
      "$date": 1586452573888
    }
  }
}*/



void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);
  float u = x / (across-1.);
  float v = y / (across-1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);
  gl_PointSize = 10.;
  gl_PointSize *= 20. / across;

  v_color = vec4(0, 1, 0, 1);
}