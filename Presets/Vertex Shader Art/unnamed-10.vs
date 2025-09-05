/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/42pYPNux6r5SL9ebp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.19215686274509805,
    0.35294117647058826,
    0.6,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 30,
    "ORIGINAL_DATE": {
      "$date": 1543837163535
    }
  }
}*/

void main() {
  gl_PointSize = 10.0;
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}