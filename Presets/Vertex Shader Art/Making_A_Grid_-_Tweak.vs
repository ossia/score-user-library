/*{
  "DESCRIPTION": "Making A Grid - Tweak",
  "CREDIT": "joonho.hwang (ported from https://www.vertexshaderart.com/art/RanZJwjv68Hjs5i4d)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 353,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684080506554
    }
  }
}*/

// Joonho Hwang
// Exercise Making a Grid
// CS250 Spring 2022

void main()
{
  float down = floor(vertexCount / 2.0);
  float isOdd = mod(vertexId, 2.0);

  float x = floor(mod(vertexId - isOdd, down));

  float u = x / (down - 2.0);

  float ux = u * 2.0 - 1.0;

  bool isVertical = vertexId < vertexCount / 2.0;
  if (isVertical)
  {
   gl_Position = vec4(ux, isOdd * 2.0 - 1.0, 0.0, 1.0);
  }
  else
  {
   gl_Position = vec4(isOdd * 2.0 - 1.0, ux, 0.0, 1.0);
  }

  v_color = vec4(1, 0, 0, 1);
}