/*{
  "DESCRIPTION": "412b synchrony - 412 bytes",
  "CREDIT": "shu (ported from https://www.vertexshaderart.com/art/SJYTAAwib5eJy8voP)", "ISFVSN": "2", "MODE":
"VERTEX_SHADER_ART", "CATEGORIES": [ "Math", "Animated"
  ],
  "POINT_COUNT": 6000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 349,
    "ORIGINAL_DATE": {
      "$date": 1486189313791
    }
  }
}*/

vec3 f(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0., 1.));
  vec4 K = vec4(1., 2. / 3., 1. / 3., 3.);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6. - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0., 1.), c.y);
}
void main() {
  float c = floor(vertexCount / 6.);
  float i = floor(vertexId / 6.);
  float j = mod(vertexId, 6.);
  gl_Position =
      vec4(i / c * 2. - 1. + (mod(j, 2.) > 0. ? 2. / c * 9. : 0.),
           j > 1. && j < 5. ? sin(i / c + mod(i, 9.) + time) : 0., -i / c, 1);
  v_color = vec4(f(vec3(c / i + time, 1, 1)), .3);
  v_color.rgb *= .3;
}
