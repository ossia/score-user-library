/*{
  "DESCRIPTION": "Exercise - Making A Grid - Hyunjin Kim",
  "CREDIT": "hyunjin-kim-dp (ported from https://www.vertexshaderart.com/art/tEAGWWrJv76hQhmjy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 581,
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
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1652850524992
    }
  }
}*/

// hyunjin Kim
// cs250 exercise - make a grid
// spring 2022

#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

vec3 hsv2rgb(vec3 c) {
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

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

 gl_Position = vec4(ux / 1.5 * cos(time), vy / 1.5 * sin(time), 0, 1);
  gl_PointSize = 10.0;

  gl_PointSize *= (40. / across) * vy * ux * abs(1. + cos(time * 2.));
  //gl_PointSize *= resolution.x / 600.;

  float count = floor(vertexId / NUM_POINTS);
  float hue = (time * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue + time, 1, 1)), 1);
}

