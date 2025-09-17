/*{
  "DESCRIPTION": "test",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/WBgJQrq6H2sZ2gzyb)",
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
    0.1450980392156863,
    0.30980392156862746,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 71,
    "ORIGINAL_DATE": {
      "$date": 1512908569240
    }
  }
}*/

void main ()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1, 0, 0, 1);
}