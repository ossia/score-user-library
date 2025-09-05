/*{
  "DESCRIPTION": "uniformgrid",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/NPohkmBgKdTBhML8P)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 151,
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
    "ORIGINAL_VIEWS": 173,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1451762849535
    }
  }
}*/

/*

Uniform Grid Based on VertexCount and window dimensions

Change the count and/or size the window

*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float across = floor(sqrt(vertexCount * resolution.x / resolution.y));
  float down = floor(vertexCount / across);

  float gx = mod(vertexId, across);
  float gy = floor(vertexId / across);

  float u = gx / (across - 1.);
  float v = gy / (down - 1.);

  float x = u * 2. - 1.;
  float y = v * 2. - 1.;
  vec2 xy = vec2(x, y);
  gl_Position = vec4(xy, 0, 1);

  float hue = u * v;
  float sat = 1.0;
  float val = 1.0;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  gl_PointSize = resolution.x / across * 0.5;
}
