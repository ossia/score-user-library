/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/fKArPmJPF5sgaDbNK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 150,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.11764705882352941,
    0.11764705882352941,
    0.11764705882352941,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1540710954935
    }
  }
}*/

mat2 Rotate2D (float x) {
  float a=sin(x), b=cos(x);
  return mat2(b, -a, a, b);
}

void main() {
  vec2 pos = vec2((vertexId/vertexCount), 0.0)*Rotate2D(vertexId+time*2.0);
  gl_PointSize = 15.0;
  gl_Position = vec4(pos, 0.0, 1.0);
  v_color = vec4(pos.x, pos.y, abs(-pos.x), 1.0)+0.5;
}