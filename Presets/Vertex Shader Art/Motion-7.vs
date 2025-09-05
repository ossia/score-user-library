/*{
  "DESCRIPTION": "Motion",
  "CREDIT": "w.chae (ported from https://www.vertexshaderart.com/art/GDZH8bzPmGJZX56xN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1684292112890
    }
  }
}*/

// Wonhyeong Chae
// Exercise Motion
// CS250 Spring 2022

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float angle = time * 2.0;
  float cosAngle = cos(angle);
  float sinAngle = sin(angle);
  float rotatedX = ux * cosAngle - vy * sinAngle;
  float rotatedY = ux * sinAngle + vy * cosAngle;

  gl_Position = vec4(tan(rotatedX), tan(rotatedY), 0., 1.);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float colorModRed = abs(sin(time * 0.5));
  float colorModGreen = abs(tan(time * 0.5));
  float colorModBlue = abs(cos(time * 0.5));

  v_color = vec4(colorModRed, colorModGreen, colorModBlue, 1.0);
}