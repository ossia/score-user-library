/*{
  "DESCRIPTION": "faster faster",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/N2YXPmoxfuJSPWjhk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated"
  ],
  "POINT_COUNT": 2,
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
      "$date": 1649487536805
    }
  }
}*/


void main() {
  float x = vertexId - 0.5;

  float duration = 30.0;
  float t = mod(time, duration);
  float v = t / duration;

  float b = fract(t * mix(1., 8., pow(v, 8.0)));
  v_color = vec4(b, b, b, 1);

  gl_Position = vec4(x, (v * 2.0 - 1.0) * vertexId, 0, 1);
  gl_PointSize = 256.0;
}