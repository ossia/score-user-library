/*{
  "DESCRIPTION": "test1",
  "CREDIT": "kerem (ported from https://www.vertexshaderart.com/art/mar5ufbpzahGtPyPj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 360,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.03529411764705882,
    0.050980392156862744,
    0.09411764705882353,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1551109281344
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 6.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float accross = floor(sqrt(vertexCount));

  float x = mod(vertexId, accross);
  float y = floor(vertexId / accross);

  // 1 2 3 4 5 6 7 8 9 0 1 2 3 4
  // 0 0 0 0 0 0 0 0 0 0 1 1 1 1

  float xoff = sin(time + y * 0.2) * 0.5;
  float yoff = sin(time + x * 0.2) * 0.5;

  float soff = sin(time + x * 0.2) * 20.;

  float ux = x / accross;
  float uy = y / accross;

  ux = 2.*ux - 1.;
  uy = 2.*uy - 1.;

  gl_Position = vec4(ux + xoff, uy + yoff, 0, 1);

  gl_PointSize = 10. + soff;

  v_color = vec4(hsv2rgb(vec3(1,1,1)), 1);

}