/*{
  "DESCRIPTION": "tutorial - Ended at lesson 3",
  "CREDIT": "allen (ported from https://www.vertexshaderart.com/art/qbuQhWtriSLNLQhJF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2532,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 24,
    "ORIGINAL_DATE": {
      "$date": 1663865890709
    }
  }
}*/

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xoff = sin(time + y * 0.2) * 0.5;
  float yoff = sin(time + x * 0.7) * 0.1;

  float ux = u * 2.0 - 1.0 + xoff;
  float vy = v * 2.0 - 1.0 + yoff;

  vec2 xy = vec2(ux, vy) * 0.75;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * vy * 0.05) * 10.0;

  gl_PointSize = 1.5 + soff;
  gl_PointSize *= 25.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float hue = u * time + 0.5;
  float sat = 1.0 * (time * 0.5);
  float value = sin(u * 20.0) * 0.5 + 0.5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, value)), 1);

}