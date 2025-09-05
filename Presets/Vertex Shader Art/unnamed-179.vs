/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "\uc815\ud559 (ported from https://www.vertexshaderart.com/art/uxbBoD5jdLBmRbdtE)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
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
    "ORIGINAL_VIEWS": 214,
    "ORIGINAL_DATE": {
      "$date": 1554210829396
    }
  }
}*/

void main()
{
  float x = floor(vertexId - 7.);
  float y = floor(vertexId - 7.);

  float u = x / 10.;
  float v = y / 10.;

  float ux = mouse.x * u * 2.;
  float vy = mouse.y * v * 2.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;

  v_color = vec4(cos(time) + 1., mouse.x, mouse.y, 1);
}