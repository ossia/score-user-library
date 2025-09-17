/*{
  "DESCRIPTION": "Bandera - Primera",
  "CREDIT": "julio (ported from https://www.vertexshaderart.com/art/tiY4qnEQ7wBnY5XdH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 347,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8156862745098039,
    0.8509803921568627,
    0.2,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1551481188410
    }
  }
}*/

void main()
{
  float width = 20.0;
  float x = mod(vertexId, width);
  float y = floor(vertexId / width);

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = sin(time + y * 0.1) * 0.5;
  float yOffset = cos(time + x * 0.4) * 0.3;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2(ux, vy) * 0.5;

  gl_Position = vec4(ux, vy, sin(time), 1.0);
  v_color = vec4(sin(time / vertexId), sin(time), cos(vertexId), sin(time));
  gl_PointSize = 40.0;
}