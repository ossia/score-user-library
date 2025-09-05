/*{
  "DESCRIPTION": "AudioReactive - AudioReactive",
  "CREDIT": "w.chae (ported from https://www.vertexshaderart.com/art/YzsRADN9oob3PHivP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1684940441735
    }
  }
}*/

// Wonhyeong Chae
// Exercise AudioReactive
// CS250 Spring 2022

#define PI radians(180.0)

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

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * .05, av * .25)).r;

  float angle = time * 0.5;
  float cosAngle = cos(angle);
  float sinAngle = sin(angle);
  float rotatedX = ux * cosAngle - vy * sinAngle;
  float rotatedY = ux * sinAngle + vy * cosAngle;

  gl_Position = vec4(rotatedX, rotatedY, 0., 1.);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = pow(snd + 0.2, 5.) * 30.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float pump = step(0.8, snd);
  float colorModRed = u * .1 + snd * 0.2 + time * .1;
  float colorModGreen = mix(0., 1., pump);
  float colorModBlue = mix(.1, pow(snd + 0.2, 5.), pump);

  v_color = vec4(colorModRed, colorModGreen, colorModBlue, 1.0);
}
