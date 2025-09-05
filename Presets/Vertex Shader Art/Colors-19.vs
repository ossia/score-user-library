/*{
  "DESCRIPTION": "Colors",
  "CREDIT": "joonho.hwang (ported from https://www.vertexshaderart.com/art/m9FwKSvyF6tR6wxKy)",
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684082918750
    }
  }
}*/

// Joonho Hwang
// Exercise Colors
// CS250 Spring 2022

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xOffset = sin(time + y * 0.2) * 0.1;
  float yOffset = sin(time * 1.1 + x * 0.3) * 0.2;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0.0, 1.0);

  float sizeOffset = sin(time * 1.2 + x * y * 0.02) * 5.0;

  gl_PointSize = 10.0 + sizeOffset;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float hue = u * 0.1 + sin(time * 1.3 + v * 20.0) * 0.05;
  float saturation = 1.0;
  float value = sin(time * 1.4 + v * u * 20.0) * 0.5 + 0.5;

  v_color = vec4(hsv2rgb(vec3(hue, saturation, value)), 1);
}