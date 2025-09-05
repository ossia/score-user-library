/*{
  "DESCRIPTION": "tutorial",
  "CREDIT": "\uc2e0\uc77c (ported from https://www.vertexshaderart.com/art/HpoPwexZeHvSos9jB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 19117,
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
    "ORIGINAL_VIEWS": 177,
    "ORIGINAL_DATE": {
      "$date": 1554078741351
    }
  }
}*/

/*
 * 1. sinil.gang
 * 2. Shader Programming / 3
 * 3. CS230
 * 4. Spring 2019
 */

void main()
{
  // X makes wide, Y too but not wide as much as X
  float tmpX = vertexId * 100.;
  float tmpY = vertexId * 1500.;

  // Variable for mouse and make Limit and adjustment
  float scopeX = mouse.x * 10.;
  float scopeY = mouse.y / 5.;

  // Conditional for preventing to make too narrow
  if(abs(scopeX) < 1.0)
  {
    scopeX += 1.0 - scopeX;
  }

  // Position setting
  gl_Position = vec4(sin(tmpX) * scopeX, sin(tmpY) * mouse.y, 0, 1);

  // Size setting
  gl_PointSize = abs(sin(time)) * 10.;

  // rgc with trigonometric function of time.
  float red = sin(time);
  float blue = cos(time);
  float green = tan(time);
  v_color = vec4(red, green, blue, 1);
}