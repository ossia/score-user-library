/*{
  "DESCRIPTION": "Play",
  "CREDIT": "jorenvo (ported from https://www.vertexshaderart.com/art/TGAHpg3tJBt7nTsRy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 19366,
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
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1557600224396
    }
  }
}*/

// from https://www.laurivan.com/rgb-to-hsv-to-rgb-for-shaders/
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float norm_sin(float x) {
  return (sin(x) + 1.) / 2.;
}

void main() {
  float size = floor(sqrt(vertexCount));
  vec2 c = vec2(mod(vertexId, size),
        floor(vertexId / size));

  float xoff = sin(time + c.y * 0.3) * .1;
  float yoff = sin(time + c.x * 0.2) * .1;
  float soff = sin(time + c.x * c.y * 0.04) * 4.;

  vec3 color = vec3(norm_sin(time + c.x / .1 + c.y / .1), 1, 1);

  // divide by the maximum to normalize to [0, 1]
  float normalizer_x = size - 1.0;
  float normalizer_y = floor((vertexCount - 1.0) / size);
  c /= vec2(normalizer_x, normalizer_y);

  // go from [0,1] -> [0,2]
  c *= 2.0;

  // go from [0,2] -> [-1, 1]
  c -= 1.0;

  c += vec2(xoff, yoff);

  c *= 1.2;

  gl_Position = vec4(c, 0, .5 + norm_sin(time + c.x * .9 + c.y * 1.1) / 2.);

  float point_size_scale = 16.0 / size;
  gl_PointSize = 15. + soff;
  gl_PointSize *= point_size_scale;
  v_color = vec4(hsv2rgb(color), 1);
}