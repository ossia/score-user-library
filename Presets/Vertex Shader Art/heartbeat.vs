/*{
  "DESCRIPTION": "heartbeat",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/uWGtoiQdrk49KSPoT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1556268030312
    }
  }
}*/

#define PI radians(180.)

float pulse(float t) {
  return pow(t, 2.);
}

void main() {
  float t = fract(time / 1.5);
  float scale = 1. -
      pulse(step(0.9, t) * (1. - t) * 10.0) * .1 -
      pulse(step(0.7, t) * step(t, 0.8) * (0.8 - t) * 10.0) * .4;

  gl_PointSize = scale * 200.0;
  gl_Position = vec4(0, 0, 0, 1);
  v_color = vec4(1, 0, 0, 1);
}