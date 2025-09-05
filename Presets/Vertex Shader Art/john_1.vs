/*{
  "DESCRIPTION": "john_1",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/BZdvckJFNr53H6kXS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 36,
    "ORIGINAL_DATE": {
      "$date": 1474782094069
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
  float uy = v * 2. - 1.;

  gl_PointSize = 10.;
  gl_PointSize *= 20. / across;

 gl_Position = vec4(ux,uy,0,1);

  v_color = vec4(1,0,0,1);
}
