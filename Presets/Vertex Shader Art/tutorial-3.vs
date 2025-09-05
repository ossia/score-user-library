/*{
  "DESCRIPTION": "tutorial",
  "CREDIT": "\uc0c1\ubbfc (ported from https://www.vertexshaderart.com/art/P7xh5mAYe3HWaA4x7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 950,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.48627450980392156,
    0.48627450980392156,
    0.48627450980392156,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1554108866812
    }
  }
}*/

void main()
{
  // gl_Position = vec4(ux, vy, 0, 1);
  gl_Position = vec4(sin(mouse.x), sin(mouse.y), 0, 1);

  gl_PointSize = abs(sin(time)) * 150.;

  v_color = vec4(1, 1, 1, 1);
}