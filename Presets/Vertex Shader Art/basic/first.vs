/*{
  "DESCRIPTION": "first",
  "CREDIT": "krankerapfel (ported from https://www.vertexshaderart.com/art/P6Gk2AsdD2B7g9Kus)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
      "$date": 1594603818637
    }
  }
}*/


void main() {

  float x = (vertexId/resolution.x) - 0.99;
  gl_Position = vec4(x, sin(x+time), sin(x+time), 1);
  gl_PointSize = 50.0;

  v_color = vec4(1,0,0,1);
}