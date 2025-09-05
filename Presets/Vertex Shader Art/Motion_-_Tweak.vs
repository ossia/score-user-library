/*{
  "DESCRIPTION": "Motion - Tweak",
  "CREDIT": "joonho.hwang (ported from https://www.vertexshaderart.com/art/HtBoKeP3qMfWwH4gB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1997,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1684082379569
    }
  }
}*/

// Joonho Hwang
// Exercise Motion
// CS250 Spring 2022

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  bool isHorizontal = vertexId < vertexCount / 2.0;

  float x = isHorizontal ? mod(vertexId, across) : floor(vertexId / across);
  float y = isHorizontal ? floor(vertexId / across) : mod(vertexId, across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xOffset = sin(time + 0.3 * length(vec2(x, y)) + y * 0.2) * 0.1;
  float yOffset = sin(time + x * 0.3) * 0.2;

  float ux = (isHorizontal ? u * 2.0 - 1.0 : u * 4.0 - 3.0) + xOffset;
  float vy = (isHorizontal ? v * 4.0 - 1.0 : v * 2.0 - 1.0) + yOffset;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0.0, 1.0);

  float sizeOffset = sin(time + x * y * 0.02) * 5.0;

  gl_PointSize = 10.0 + sizeOffset;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1, 0, 0, 1);
}