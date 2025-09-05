/*{
  "DESCRIPTION": "Moving Grid - And now... it moves!",
  "CREDIT": "paul-jan (ported from https://www.vertexshaderart.com/art/7EeTjhnP4EshLL5B2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 4000,
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
      "$date": 1485895235817
    }
  }
}*/


vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float across = floor(sqrt(vertexCount));

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xoff = sin(time + 0.2 * y) * 0.1 * 1000. / vertexCount;
  float yoff = sin(time * 1.1 + 0.3 * x) * 0.2 * 1000. / vertexCount;

  float ux = 2.0 * u - 1.0 + xoff;
  float uy = 2.0 * v - 1.0 + yoff;

  vec2 xy = vec2(ux, uy) * 1.3;

  float soff = sin(time * 1.2 + x * y * 0.02) * 5.;

  float hue = 0.5 + 0.1 * u + 0.1 * sin(time * 1.3 + v * 20.);
  float sat = 0.5;
  float val = .8 + sin(time * 1.4 + u * v * 20.0) * 0.5;

  gl_Position = vec4(xy, 0, 1);
  gl_PointSize = 15.0 * 20.0 / across + soff;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}