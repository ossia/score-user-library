/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ZNyqShZSnzXJMjTPX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 256,
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
    "ORIGINAL_VIEWS": 93,
    "ORIGINAL_DATE": {
      "$date": 1565302288274
    }
  }
}*/

// -----[ shader missing! ] -----

#define NUM 15.0
void main() {
  gl_PointSize = 16.0;
  float col = mod(vertexId, NUM + 1.0);
  float row = mod(floor(vertexId / NUM), NUM + 1.0);
  float x = col / NUM * 2.0 - 1.0;
  float y = row / NUM * 2.0 - 1.0;
  gl_Position = vec4(x, y, 0, 1);
  v_color = vec4(fract(time + col / NUM + row / NUM), 0, 0, 1);

}