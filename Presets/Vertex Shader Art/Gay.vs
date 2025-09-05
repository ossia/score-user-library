/*{
  "DESCRIPTION": "Gay",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/DagQjjsyoq4ygNS4K)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 32,
    "ORIGINAL_DATE": {
      "$date": 1699315554530
    }
  }
}*/

void main()
{
  v_color = vec4(0.0, 0.0, 0.0, 1.0);
  gl_PointSize = 20.0;

  float width = 10.0;

  float x = mod(vertexId, width);
  float y = floor(vertexId / width);

  x = x / (width - 1.0);
  y = y / (width - 1.0);

  x = x * 2.0 - 1.0;
  y = y * 2.0 - 1.0;

  float xOffset = cos(time + y * 0.2) * 0.1;
  float yOffset = cos(time + x * 0.3) * 0.2;

  x = x + xOffset;
  y = y + yOffset;

  vec2 xy = vec2(x, y) * 0.5;

  gl_Position = vec4(xy, 0.0, 1.0);
}