/*{
  "DESCRIPTION": "2d-plot-stuff",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/HXzN44Rci8MBYDQYL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1528819017360
    }
  }
}*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float u = vertexId / vertexCount;
  float v = u;

  v = pow(v, .1);
  v = pow(v, 10.);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(u, v);
  gl_Position = vec4(xy * 2. - 1., 0, 1);

  float hue = (u);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
  gl_PointSize = 10.0;
}