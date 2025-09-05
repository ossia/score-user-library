/*{
  "DESCRIPTION": "My programing class",
  "CREDIT": "jc (ported from https://www.vertexshaderart.com/art/ZWM6nHwzqNcfrMCbQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3923,
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
    "ORIGINAL_VIEWS": 622,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1517618846596
    }
  }
}*/

void main()
{
  float width = floor(sqrt(vertexCount));

  float x = mod(vertexId, width);
  float y = floor(vertexId / width);

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = cos(time + y * 0.2) * 0.1;
  float yOffset = cos(time + x * 0.3) * 0.2;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  // vertexId 0 1 2 ... 10 11 12 13 ... 20 21 22
  //mod 0 1 2 ... 0 1 2 3 ... 0 1 2 (residuo) X
  //floor 0 0 0 ... 1 1 1 1 ... 2 2 2 (divididos) Y

  vec2 xy = vec2(ux, vy) * 1.2;

  gl_Position = vec4 (xy, 0.0, 1.0);

  float sizeOffset = sin(time + x * y * 0.2) * 5.0;
  gl_PointSize = 10.0 + sizeOffset;
  gl_PointSize *= 32.0 / width;

  v_color= vec4(0.0, 1.0, 0.0, 1.0);
}