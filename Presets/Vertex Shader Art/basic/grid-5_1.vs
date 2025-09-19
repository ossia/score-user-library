/*{
  "DESCRIPTION": "grid",
  "CREDIT": "iguacel (ported from https://www.vertexshaderart.com/art/PaksuLs2j2rAHuzxw)",
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
    0.07058823529411765,
    0.11372549019607843,
    0.32941176470588235,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1672697722362
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

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.; // sin(time + y * 0.2) * 0.1;
  float yoff = 0.; //sin(time + x * 0.3) * 0.1;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float scale = 0.8;
  vec2 xy = vec2(ux, vy) * scale;

  gl_Position = vec4(xy, 0., 1.);

  float soff = 0.; // sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float hue = u;
  float sat = v;
  float val = 1.;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.);
}