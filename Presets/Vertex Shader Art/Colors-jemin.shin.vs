/*{
  "DESCRIPTION": "Colors-jemin.shin",
  "CREDIT": "jeminshin2 (ported from https://www.vertexshaderart.com/art/BLAH5H2ctKjDqzabc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1684479150672
    }
  }
}*/

//Name : Jemin.Shin
//Exercise - Vertexshaderart : Colors
//Course : CS250
//Date : 2023 Spring

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
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
  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

   float ux = u * 2.0 - 1.0 * xoff;
   float vy = v * 2.0 - 1.0 + yoff;

   vec2 xy = vec2(ux , vy);

   gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * .02) * 5.;

   gl_PointSize = 15.0 + soff;
   gl_PointSize *= 20.0 / across;
   gl_PointSize *= resolution.x / 600.;

  float hue = u * .1 + sin(time +v * 20.) * 0.05;
  float sat = 1.;
  float val = sin(time + v * u * 20.0);

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}