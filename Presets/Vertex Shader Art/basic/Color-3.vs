/*{
  "DESCRIPTION": "Color - Exercise Color\nCS250 Spring 2023",
  "CREDIT": "w.chae (ported from https://www.vertexshaderart.com/art/qh4PDg5QYbN3rGiXh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
      "$date": 1684292715495
    }
  }
}*/

// Wonhyeong Chae
// Exercise Color
// CS250 Spring 2022

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float centerX = (across - 1.) / 2.0;
  float centerY = (down - 1.) / 2.0;

  float xOffset = x - centerX;
  float yOffset = y - centerY;

  float normalizedX = xOffset / centerX;
  float normalizedY = yOffset / centerY;

  float spread = 0.5;
  float spreadX = normalizedX * spread;
  float spreadY = normalizedY * spread;

  float u = (normalizedX + 1. + spreadX) / 2.;
  float v = (normalizedY + 1. + spreadY) / 2.;

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float angle = time * 0.5;
  float cosAngle = cos(angle);
  float sinAngle = sin(angle);
  float rotatedX = ux * cosAngle - vy * sinAngle;
  float rotatedY = ux * sinAngle + vy * cosAngle;

  gl_Position = vec4(rotatedX, rotatedY, 0., 1.);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float colorModRed = u * .1 + sin(time * 1.3 + v * 20.) * 0.05;
  float colorModGreen = 1.;
  float colorModBlue = sin(time * 1.4 + v * u * 20.0) * .5 + .5;

  v_color = vec4(colorModRed, colorModGreen, colorModBlue, 1.0);
}
