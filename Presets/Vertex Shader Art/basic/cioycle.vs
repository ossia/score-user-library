/*{
  "DESCRIPTION": "cioycle",
  "CREDIT": "refactorized (ported from https://www.vertexshaderart.com/art/6XqJX2mnFpa8i9aLH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 457,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1567132989286
    }
  }
}*/

const float tau = 6.28318530718;
const float cycles = 42.0;
const float wrap = 17.0;

void main() {
  float ratio = vertexId / vertexCount;
  float modio = mod((ratio * wrap), 1.0);
  float theta = ratio * tau * cycles;
  float tmod = modio * tau * cycles;
  gl_Position = vec4(sin(tmod) * ratio, cos(tmod) * ratio, 0, 1);
  gl_PointSize = 22.0;
  v_color = vec4(
    0.5 + sin(theta) / 2.0,
    0.5 + sin(theta + tau/3.0) / 2.0,
    0.5 + sin(theta + 2.0 * tau / 3.0) / 2.0,
    0.0 ) * 1.2 * (1.0 - ratio);
}