/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "\uc9c0\uc218 (ported from https://www.vertexshaderart.com/art/2XgSDRuhBYPBvZ9QX)",
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
    0.25098039215686274,
    0,
    0.5019607843137255,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1554193654607
    }
  }
}*/

void main()
{
  float across = 10.0;

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across-1.0);
  float v = y / (across-1.0);

  float ux = u *2.0 - 1.0;
  float vy = v *2.0 - 1.0;

  gl_Position = vec4(ux, vy, 0.0, 1.0);

  v_color = vec4(mouse.x, mouse.y, 0.0, 1.0);

  gl_PointSize = abs(cos(time)*100.0);
}

