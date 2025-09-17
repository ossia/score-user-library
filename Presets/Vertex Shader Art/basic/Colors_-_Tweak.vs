/*{
  "DESCRIPTION": "Colors - Tweak",
  "CREDIT": "joonho.hwang (ported from https://www.vertexshaderart.com/art/xc49q3XhWdr4G5g3Y)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3358,
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
      "$date": 1684083353220
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

  float hue = sin(time * u * v) * 0.5 + 0.5;
  float saturation = sin(time * length(vec2(x, y))) * 0.5 + 0.5;
  float value = 1.0;

  v_color = vec4(hsv2rgb(vec3(hue, saturation, value)), 1);
}