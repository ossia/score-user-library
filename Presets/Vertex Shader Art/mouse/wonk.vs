/*{
  "DESCRIPTION": "wonk",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/uQ6SBCL37HsvsjWYy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 400,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 33,
    "ORIGINAL_DATE": {
      "$date": 1639585711620
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float count = floor(vertexId / NUM_POINTS);
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(((sin(vertexId * time)*8.0) / resolution.x) * count, ((cos(vertexId * time)*4.0) / resolution.y) * count);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (time * 0.01 + (count/10.0) * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}
