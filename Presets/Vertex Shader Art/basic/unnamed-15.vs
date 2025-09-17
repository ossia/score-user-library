/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "\uc815\ud559 (ported from https://www.vertexshaderart.com/art/5rPSkvavMCsT3A4KY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 75,
    "ORIGINAL_DATE": {
      "$date": 1554208672201
    }
  }
}*/

void main()
{
  float across = 10.;

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / across;
  float v = y / across;

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;

  v_color = vec4(1, 0, 0, 1);
}