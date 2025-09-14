/*{
  "DESCRIPTION": "190331 - mouse interaction.\ncolor changing.\nmove around.",
  "CREDIT": "\ub2e4\uc740 (ported from https://www.vertexshaderart.com/art/8cPTCz9Cm8iRKNmqG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1554024064167
    }
  }
}*/

// your name (daeun Jeong)
// the assignment number (03)
// the course name (CS230)
// the term (Spring 2019)

void main()
{
  float xOff = sin(time) * 0.2;

  float yOff = cos(time) * 0.2;

  float blueOff = abs(cos(time));

  float alphaOff = abs(sin(time)) + 0.5;

  float sizeOff = abs(sin(time)) * 10.0 + 10.0;

  vec4 pos = vec4(mouse.x + xOff, mouse.y + yOff, 0.0, 1.0);

  gl_Position = pos;

  gl_PointSize = sizeOff;

  v_color = vec4(0.1, 0.1, blueOff, alphaOff);
}